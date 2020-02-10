# frozen_string_literal: true

module Api

  module V1

    class PlansController < BaseApiController

      respond_to :json

      # GET /api/v1/plans/:id
      def show
        plans = Plan.where(id: params[:id]).limit(1)
        @items = paginate_response(results: plans)
        render "/api/v1/plans/index", status: :ok
      end

      # POST /api/v1/plans
      def create
        render "/api/v1/plans/index", status: :ok
      end

      private

      def dmp_params
        params.require(:dmp).permit(plan_permitted_params).to_h
      end

    end

  end

end
