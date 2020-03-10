# frozen_string_literal: true

module Api

  class ContributorPresenter

    class << self

      # Convert the specified role into a CRediT Taxonomy URL
      def role_as_uri(role:)
        return nil unless role.present?

        "#{Contributor::ONTOLOGY_BASE_URL}/#{role.to_s.capitalize}"
      end

    end

  end

end
