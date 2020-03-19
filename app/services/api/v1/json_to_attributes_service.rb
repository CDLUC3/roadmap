# frozen_string_literal: true

module Api

  module V1

    class JsonToAttributesService

      class << self
        # ===========================
        # JSON API PARAMS TO MODELS #
        # ===========================

        # Convert the incoming JSON into an Identifier
        def identifier_from_json(json: {})
          return nil unless json.present?

          json = json.with_indifferent_access
          return nil unless json[:identifier].present? && json[:type].present?

          scheme = IdentifierScheme.by_name(json[:type].downcase).first
          Identifier.find_or_initialize_by(identifier_scheme: scheme,
                                           value: json[:identifier].to_s)
        end

        # Convert the incoming JSON into an Org
        def org_from_json(json: {})
          return nil unless json.present?

          json = json.with_indifferent_access
          id = json.fetch(:affiliation_id, json.fetch(:funder_id, {}))
          return nil unless json[:name].present? || id.present?

          # First try to find the Org by any identifiers
          if id.present?
            org = Org.from_identifiers(array: [
              { name: id[:type], value: id[:identifier] }
            ])
          end

          # Otherwise try to find it by name (local DB, external API or a new one)
          org = org_search_by_name(json: json) unless org.present?
          return nil unless org.present?

          # Org model requires a language sso just use the default for now
          org.language = Language.find_by(default_language: true)
          org.abbreviation = json[:abbreviation] if json[:abbreviation].present?
          org.save

          id = identifier_from_json(json: id)
          return org unless id.present? && !id.identifiable.present?

          # Save the identifier if its new
          id.identifiable = org
          id.save
          org.reload
          org
        end

        # Convert the incoming JSON into a Contributor
        def contributor_from_json(plan:, json: {})
          return nil unless json.present? && plan.present?

          json = json.with_indifferent_access
          return nil unless json[:mbox].present? && json[:name].present?

          # Retrieve the Org
          org = org_from_json(json: json[:affiliation]) if json[:affiliation].present?

          # First try to find the Contributor by any identifiers
          id = json.fetch(:contributor_id, json.fetch(:contact_id, {}))
          contrib = Contributor.where(plan_id: plan.id)
                               &.from_identifiers(array: [{ name: id[:type],
                                                            value: id[:identifier] }])

          # Search by email if available and not found above
          if !contrib.present?
            contrib = Contributor.find_by(plan_id: plan.id, email: json[:mbox])
          end

          # Otherwise create a new one
          contrib = Contributor.new(plan_id: plan.id, name: json[:name],
                                    email: json[:mbox]) unless contrib.present?

          # Attach the org affiliation unless its already defined
          contrib.org = org unless contrib.org.present?

          # Add the role
          if json[:contact_id].present?
            # Contact is an author and curator
            contrib.data_curation = true
            contrib.writing_original_draft = true
          else
            json.fetch(:role, []).each do |url|
              role = translate_role(role: url)
              contrib.send(:"#{role}=", true) if role.present?
            end
          end

          contrib.plan = plan
          contrib.save

          # If found combine existing identifiers with new ones
          identifier = identifier_from_json(json: id)
          return contrib unless identifier.present? && !identifier.identifiable.present?

          # Save the identifier if its new
          identifier.identifiable = contrib
          identifier.save
          contrib.reload
          contrib
        end

        def funding_from_json(plan:, json:)
          return plan unless json.present?

          json = json.with_indifferent_access
          project = json.fetch(:project, [{}]).first

          # Process Funder
          if project.present?
            funder_affil = project.fetch(:funding, []).first
            funder = org_from_json(json: funder_affil) if funder_affil.present?

            # Attach the Funder
            plan.funder = funder if funder.present?

            # Attach the Grant id to the plan
            if funder_affil.present?
              if funder_affil[:grant_id].present?
                grant_id = identifier_from_json(json: funder_affil[:grant_id])

                if grant_id.present? && !grant_id.identifiable.present?
                  grant_id.identifiable = plan
                  grant_id.save
                  plan.grant_id = grant_id.id
                  plan.save
                end
              end
            end
          end

          plan.reload
          plan
        end

        # Convert the incoming JSON into a Plan
        def plan_from_json(plan: nil, json: {})
          return nil unless json.present?

          json = json.with_indifferent_access
          dmp_id = json.fetch(:dmp_id, {})
          return nil unless json[:title].present? &&
                            json[:contact].present? &&
                            json[:contact][:name].present? &&
                            json[:contact][:mbox].present?

          # First try to find the plan by any identifiers
          if plan.nil? && dmp_id[:identifier].present?
            plan = Plan.find_by(id: dmp_id[:identifier].split("/").last) if dmp_id[:type] == "url"

            plan = Plan.from_identifiers(array: [
              { name: dmp_id[:type], value: dmp_id[:identifier]}
            ]) unless plan.present?
          end

          # If this is not an existing Plan, then initialize a new one
          # for the specified template (or the default template if none specified)
          template_id = fetch_template(array: json.fetch(:extended_attributes, []))
          plan = Plan.new(template_id: template_id) unless plan.present?

          plan.title = json[:title]

          project = json.fetch(:project, [{}]).first
          project = {} unless project.present?
          plan.description = json.fetch(:description, project[:description])
          plan.start_date = project[:start]
          plan.end_date = project[:end]

          # TODO: Handle ethical issues when question is in place

          # Process Contributors and Data Contact
          contact = contributor_from_json(plan: plan, json: json[:contact])
          return nil unless contact.present?

          # Attach the default roles to the contact
          contact.data_curation = true
          contact.writing_original_draft = true
          contact.save

          contributors = json.fetch(:contributor, []).map do |hash|
            contributor_from_json(plan: plan, json: hash)
          end

          plan.contributors << contributors.compact if contributors.any?
          plan.contributors << contact if contact.present?

          # Attach the Contact's org
          plan.org = contact.org

          plan.save
          plan = funding_from_json(plan: plan, json: json)
          plan
        end

        def cost_from_json(json: {})
          # TODO: Need to implement dmp costs in the data model
        end

        def dataset_from_json(json: {})
          # TODO: Need to implement multi-datasets in the data model
        end

        # Extract the template id from the `extended_attributes`
        def fetch_template(array:)
          app = ApplicationService.application_name.split("-").first
          app_extensions = array.select { |ext| ext[app].present? }
          templates = app_extensions.select do |hash|
            hash[app.to_sym].fetch(:template, {})[:id].present?
          end
          return templates.first[app.to_sym].fetch(:template, {})[:id] if templates.any?

          Template.default&.id
        end

        # Extract the plan id from the URL or use the doi/ark
        def fetch_plan_id(json:)
          return nil unless json.present? && json[:identifier].present? &&
                            json[:type].present?

          return json[:identifier].split("/").last if json[:type] == "url"

          %w[ark doi].include?(json[:type]) ? json[:identifier] : nil
        end

        private

        # Search for an Org locally and then externally if not founds
        def org_search_by_name(json:)
          name = json[:name]
          return nil unless name.present?

          # Search the DB
          org = Org.where("LOWER(name) = ?", name.downcase).first
          return org if org.present?

          # External ROR search
          results = OrgSelection::SearchService.search_externally(search_term: name)

          # Grab the closest match - only caring about results that 'contain' the
          # name with preference to those that start with the name
          result = results.select { |r| %i[0 1].include?(r[:weight]) }.first

           # If no good result was found just use the specified name
          result = { name: name } unless result
          OrgSelection::HashToOrgService.to_org(hash: result)
        end

        # Translates the role in the json to a PlansContributor role
        def translate_role(role:)
          default = "writing_original_draft"
          return default unless role.present?

          url = Contributor::ONTOLOGY_BASE_URL
          # Strip off the URL if present
          role = role.gsub("#{url}/", "").downcase if role.include?(url)

          # Return the role if its a valid one otherwise defualt
          return role if Contributor.new.respond_to?(role.downcase.to_sym)

          default
        end

      end

    end

  end

end
