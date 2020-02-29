# frozen_string_literal: true

module Api

  class PlansContributorPresenter

    class << self

      # Convert the specified role into a CRediT Taxonomy URL
      def role_as_uri(role:)
        return nil unless role.present?

        "#{PlansContributor::CREDIT_TAXONOMY_URI_BASE}/#{role.to_s.capitalize}"
      end

    end

  end

end
