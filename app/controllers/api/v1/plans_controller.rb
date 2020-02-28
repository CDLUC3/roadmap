# frozen_string_literal: true

module Api

  module V1

    class PlansController < BaseApiController

      respond_to :json

      # GET /api/v1/plans/:id
      def show
        plans = Plan.where(id: params[:id]).limit(1)

        if client.is_a?(User) && plans.any?
          # If the specified plan does not belong to the org or the owner's org
          if plans.first.org_id != client.org_id &&
              plans.first.owner&.org_id != client.org_id

            # Kaminari pagination requires an Activeecord resultset :/
            plans = Plan.where(id: nil).limit(1)
          end
        else
          # TODO: Need to consider security here? How do we limit what an
          #       ApiClient can see? Do we even need/want to?
        end

        if plans.any?
          @items = paginate_response(results: plans)
          render "/api/v1/plans/index", status: :ok
        else
          render_error(errors: [_("Plan not found")], status: :not_found)
        end
      end

      # POST /api/v1/plans
      def create
        dmp = @json.with_indifferent_access.fetch(:items, []).first.fetch(:dmp, {})
        plan = Api::JsonToAttributesService.plan_from_json(json: dmp)

        if plan.present?
          if plan.new_record?

p "PLAN:"
p plan.inspect
p plan.identifiers.inspect
p "-----------------------------------"
p "FUNDER:"
p plan.funder.inspect
p plan.funder.identifiers.inspect

            # Handle all the identifiers until accepts_attributes_for is working

            if plan.save
              @items = [plan]

              # Handle any new user invitations

              render "/api/v1/plans/index", status: :ok
            else
              render_error(errors: plan.errors.full_messages, status: :bad_request)
            end

          else
            render_error(
              errors: [_("Plan already exists. Send an update instead")],
              status: :bad_request
            )
          end
        else
          render_error(errors: [_("Invalid JSON")], status: :bad_request)
        end
      end

      private

      def dmp_params
        params.require(:dmp).permit(plan_permitted_params).to_h
      end

    end

  end

end
