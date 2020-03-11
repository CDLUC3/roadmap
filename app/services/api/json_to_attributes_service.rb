# frozen_string_literal: true

module Api

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
        return nil unless scheme.present?

        # Extract the landing page URL for the scheme so that we only save
        # the identifier in the event that the URL ever changes
        landing = scheme.user_landing_url&.downcase
        value = landing.present? ? json[:identifier].to_s.downcase.gsub(landing, "") : json[:identifier]

        Identifier.find_or_initialize_by(identifier_scheme: scheme, value: value)
      end

      # Convert the incoming JSON into an Org
      def org_from_json(json: {})
        return nil unless json.present?

        json = json.with_indifferent_access

        affiliation_ids = json.fetch(:affiliation_ids, json.fetch(:funder_ids, []))
        return nil unless json[:name].present? || affiliation_ids.any?

        # First try to find the Org by any identifiers
        array = affiliation_ids.map do |id|
          { name: id[:type], value: id[:identifier] }
        end
        org = Org.from_identifiers(array: array)

        # Otherwise try to find it by name (local DB, external API or a new one)
        org = org_search_by_name(json: json) unless org.present?
        return nil unless org.present?

        # If found combine existing identifiers with new ones
        org.consolidate_identifiers!(
          array: identifiers_from_json(array: affiliation_ids))

        # Org model requires a language sso just use the default for now
        org.language = Language.find_by(default_language: true)
        org.abbreviation = json[:abbreviation] if json[:abbreviation].present?
        org
      end

      # Convert the incoming JSON into a Contributor
      def contributor_from_json(plan:, json: {})
        return nil unless json.present? && plan.present?

        json = json.with_indifferent_access
        contributor_ids = json.fetch(:contributor_ids, [])
        return nil unless json[:mbox].present?

        # Retrieve the Org
        affiliations = json.fetch(:affiliations, [])
        org = org_from_json(json: affiliations.first) if affiliations.any?

        # First try to find the Contributor by any identifiers
        array = contributor_ids.map do |id|
          { name: id[:type], value: id[:identifier] }
        end
        contrib = Contributor.where(plan_id: plan.id)
                             &.from_identifiers(array: array)

        # Search by email if available and not found above
        if !contrib.present? && json[:mbox].present?
          contrib = Contributor.find_by(plan_id: plan.id, email: json[:mbox])
        end

        # Otherwise create a new one
        contrib = Contributor.new(plan_id: plan.id,
                                  firstname: json[:firstname],
                                  surname: json[:surname],
                                  email: json[:mbox]) unless contrib.present?

        # Attach the org affiliation unless its already defined
        contrib.org = org unless contrib.org.present?

        # If found combine existing identifiers with new ones
        contrib.consolidate_identifiers!(
          array: identifiers_from_json(array: contributor_ids))

        # Add the role
        role = translate_role(role: json[:role])
        contrib.send(:"#{role}=", true)

        contrib
      end

      # Convert the incoming JSON into a Plan
      def plan_from_json(json: {})
        return nil unless json.present?

        json = json.with_indifferent_access
        dmp_ids = json.fetch(:dmp_ids, [])
        return nil unless json[:title].present? && json[:contact].present? &&
                          json[:project].present? # && json[:datasets].any?

        # First try to find the plan by any identifiers
        array = dmp_ids.map { |id| { name: id[:type], value: id[:identifier] } }
        id = array.select { |i| i[:name] == ApplicationService.application_name }.first
        plan = Plan.find_by(id: id[:value]) if id.present? && id[:value].present?

        plan = Plan.from_identifiers(array: array) unless plan.present?

        # If this is not an existing Plan, then initialize a new one
        # for the specified template (or the default template if none specified)
        template_id = fetch_template(array: json.fetch(:extended_attributes, []))
        plan = Plan.new(template_id: template_id) unless plan.present?

        plan.title = json[:title]
        plan.description = json.fetch(:description, json[:project][:description])
        plan.start_date = json[:project][:start_on]
        plan.end_date = json[:project][:end_on]

        plan.ethical_issues = Api::ConversionService.yes_no_unknown_to_boolean(
          json[:ethical_issues_exist])
        plan.ethical_issues_description = json[:ethical_issues_description]
        plan.ethical_issues_report = json[:ethical_issues_report]

        # Process Contributors and Data Contact
        contact = contributor_from_json(plan: plan, json: json[:contact])
        contact.data_curation = true
        contact.writing_original_draft = true

        contributors = json.fetch(:contributors, []).map do |hash|
          contributor_from_json(plan: plan, json: hash)
        end

        plan.contributors << contributors.compact if contributors.any?
        plan.contributors << contact if contact.present?

        # Process Funder
        funder_affil = json[:project].fetch(:funding, []).first
        funder = org_from_json(json: funder_affil) if funder_affil.present?

        # Attach the Funder and Contact's org
        plan.funder = funder
        plan.org = contact.org

        # Attach any grant ids to the plan
        if funder_affil.present?
          grant_ids = identifiers_from_json(array:
            [funder_affil.fetch(:grant_id, {})])

          plan.consolidate_identifiers!(array: grant_ids) if grant_ids.any?
          plan.grant_id = grant_ids.first.id if grant_ids.first.present?
        end

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
        app = ApplicationService.application_name
        app_extensions = array.select { |ext| ext[app.to_sym].present? }
        templates = app_extensions.select do |hash|
          hash[app.to_sym][:template_id].present?
        end
        return templates.first[app.to_sym][:template_id] if templates.any?

        Template.default&.id
      end

      private

      # Convert the array of JSON objectss into Identifiers
      def identifiers_from_json(array:)
        array.collect { |item| identifier_from_json(json: item) }.compact
      end

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
