# frozen_string_literal: true

module Api

  class JsonToAttributesService

    class << self
      # ===========================
      # JSON API PARAMS TO MODELS #
      # ===========================
      def identifier_from_json(json: {})
        return nil unless json[:identifier].present? && json[:type].present?

        scheme = IdentifierScheme.by_name(json[:type].downcase).first

        # Extract the landing page URL for the scheme so that we only save
        # the identifier in the event that the URL ever changes
        value = json[:identifier].downcase.gsub(scheme.user_landing_url.downcase, "")

        Identifier.find_or_initialize_by(identifier_scheme: scheme, value: value)
      end

      def org_from_json(json: {})
        affiliation_ids = json.fetch(:affiliation_ids, [])
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

      def cost_from_json(json: {})
        # TODO: Need to implement dmp costs in the data model
      end

      def dataset_from_json(json: {})
        # TODO: Need to implement multi-datasets in the data model
      end

      private

      def identifiers_from_json(array:)
        array.collect { |item| identifier_from_json(json: item) }.compact
      end

      # Search for an Org
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
