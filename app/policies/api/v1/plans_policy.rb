# frozen_string_literal: true

module Api

  module V1

    class PlansPolicy < BasePolicy

      attr_reader :client
      attr_reader :plan

      def initialize(client, plan)
        authorize(client: client, context: plan)
      end

      def create?
        @client.present? && @plan.template.present?
      end

      def index?
        @client.present?
      end

    end

  end

end
