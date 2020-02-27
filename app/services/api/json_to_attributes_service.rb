# frozen_string_literal: true

module Api

  class JsonToAttributesService

    class << self
      # ===========================
      # JSON API PARAMS TO MODELS #
      # ===========================

      # Convert the incoming JSON into an Identifier
      def identifier_from_json(json: {})
        return nil unless json[:identifier].present? && json[:type].present?

        scheme = IdentifierScheme.by_name(json[:type].downcase).first

        # Extract the landing page URL for the scheme so that we only save
        # the identifier in the event that the URL ever changes
        value = json[:identifier].downcase.gsub(scheme.user_landing_url.downcase, "")

        Identifier.find_or_initialize_by(identifier_scheme: scheme, value: value)
      end

      # Convert the incoming JSON into an Org
      def org_from_json(json: {})
        affiliation_ids = json.fetch(:affiliation_ids, json.fetch(:funder_ids, []))
        return nil unless json[:name].present? || affiliation_ids.any?

        # First try to find the Org by any identifiers
        array = affiliation_ids.map do |id|
          { name: id[:type], value: id[:identifier] }
        end
        org = Org.from_identifiers(array: array)

        # Otherwise try to find it by name (local DB, external API or a new one)
        org = org_search_by_name(name: json) unless org.present?
        return nil unless org.present?

        # If found combine existing identifiers with new ones
        org.consolidate_identifiers(
          identifiers: identifiers_from_json(array: affiliation_ids))

        org
      end

      # Convert the incoming JSON into a Contributor
      def contributor_from_json(json: {})
        contributor_ids = json.fetch(:contributor_ids, [])
        return nil unless json[:email].present? ||
                          json[:surname].present? ||
                          contributor_ids.any?

        # Retrieve the Org
        affiliations = json.fetch(:affiliations, [])
        org = org_from_json(json: affiliations.first) if affiliations.any?

        # First try to find the Contributor by any identifiers
        array = contributor_ids.map do |id|
          { name: id[:type], value: id[:identifier] }
        end
        contrib = Contributor.from_identifiers(array: array)

        # Otherwise create a new one
        contrib = Contributor.new(firstname: json[:firstname],
                                  surname: json[:surname],
                                  email: json[:mbox]) unless contrib.present?

        # If found combine existing identifiers with new ones
        contrib.consolidate_identifiers(
          identifiers: identifiers_from_json(array: contributor_ids))

        contrib
      end

      def plan_from_json(json: {})
        dmp_ids = json.fetch(:dmp_ids, [])
        return nil unless json[:title].pressent? && json[:contact].present? &&
                          json[:project].present? # && json[:datasets].any?

        # Process Contributors and Data Contact
        contact = contributor_from_json(json: json[:contact])
        contributors = json.fetch(:contributors, []).map do |hash|
          contributor_from_json(json: hash)
        end

        # Process Funder
        funder_affil = json[:project].fetch(:funding, []).first
        funder = org_from_json(json: funder_affil) if funder_affil.present?

        # First try to find the plan by any identifiers
        array = dmp_ids.map { |id| { name: id[:type], value: id[:identifier] } }

        # If one of the identifiers is a DMPTool Plan id
        id = array.select { |i| i[:name] == Api::ConversionService.application_name }
        plan = Plan.find_by(id: id) if id.present?

        plan = Plan.from_identifiers(array: array) unless plan.present?

        # If this is not an existing Plan, then initialize a new one
        # for the specified template (or the default template if none specified)
        template_id = json.fetch(:extended_attributes, {}).fetch(:dmptool, {})
                          .fetch(:template_id, Template.default.pluck(:id))
        plan = Plan.new(template_id: template_id) unless plan.present?

        plan.title = json[:title]
        plan.description = json.fetch(:description, json[:project][:description])
        plan.start_date = json[:project][:start_on]
        plan.end_date = json[:project][:end_on]

        plan.ethical_issues = ConversionService.yes_no_unknown_to_boolean(
          json:[:ethical_issues_exist])
        plan.ethical_issues_description = json[:ethical_issues_description]
        plan.ethical_issues_report = json[:ethical_issues_report]

        # Attach the Funder and Contact's org
        plan.funder = funder

        # Attach the contributors
        plan.contributors = contributors if contributors.any?
        plan.contributors << contact if contact.present?

        # Attach any grant ids to the plan
        grants = funder_affil.fetch(:grant_ids, []).map do |hash|
          identifier_from_json(json: hash)
        end
        plan.identifiers + grants if grants.any?

        plan
      end

      def cost_from_json(json: {})
        # TODO: Need to implement dmp costs in the data model
      end

      def dataset_from_json(json: {})
        # TODO: Need to implement multi-datasets in the data model
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
        org = Org.search(name).first
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

    end

  end

end
