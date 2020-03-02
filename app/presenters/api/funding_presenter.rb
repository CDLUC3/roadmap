# frozen_string_literal: true

module Api

  class FundingPresenter

    class << self

      # If the plan has a grant number then it has been awarded/granted
      # otherwise it is 'planned'
      def status(plan:)
        return "planned" unless plan.present? && plan.grant_number.present?

        return "granted"
      end

    end

  end

end