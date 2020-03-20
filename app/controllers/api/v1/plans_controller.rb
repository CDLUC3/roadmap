# frozen_string_literal: true

module Api

  module V1

    class PlansController < BaseApiController

      include ConditionalUserMailer

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

        now = (Time.now - 1.minute)
        plan = Api::V1::JsonToAttributesService.plan_from_json(json: dmp)

        if plan.present?
          if plan.new_record?
            render_error(errors: plan.errors.full_messages, status: :bad_request)

          elsif plan.created_at.utc < now.utc
            render_error(errors: _("Plan already exists. Send an updated instead."),
                         status: :bad_request)

          else
            # Attach all of the authors and then invite them if necessary
            plan.contributors.writing_original_draft.each do |author|
              identifiers = author.identifiers.map do |id|
                { name: id.identifier_scheme.name, value: id.value }
              end
              user = User.from_identifiers(array: identifiers) if identifiers.any?
              user = User.find_by(email: author.email) unless user.present?

# ========================================
# Start DMPTool Customization
#   commenting out user invite for testing
# ========================================
              # Only do this step in production!
              # If the user was not found, invite them and attach any know identifiers
              #if Rails.env.production? && user.blank?
                # Handle any new user invitations
                #user = User.invite!(email: author.email,
                #                    firstname: author.firstname,
                #                    surname: author.surname)

                #author.identifiers.each do |id|
                #  user.identifiers << Identifier.new(
                #    identifier_scheme: id.identifier_scheme, value: id.value)
                #end
              #end
# ========================================
# End DMPTool Customization
# ========================================
              next unless user.present?

              # Attach the role
              role = Role.new(user: user, plan: plan)
              role.creator = true if author.data_curation?
              role.administrator = true if author.writing_original_draft? &&
                                          !author.data_curation?
              role.save

# ========================================
# Start DMPTool Customization
#   Stub DOI minting and email devs
# ========================================
              doi = IdentifierScheme.by_name("doi").first

              if doi.present?
                Identifier.create(identifiable: plan, identifier_scheme: doi,
                                  value: SecureRandom.uuid)
                plan = plan.reload
              end

              contact = plan.contributors.select(&:data_curation?).first
              #UserMailer.api_plan_creation(plan, contact).deliver_now
# ========================================
# End DMPTool Customization
# ========================================

            end

            # Kaminari Pagination requires an ActiveRecord result set :/
            @items = paginate_response(results: Plan.where(id: plan.id))
            render "/api/v1/plans/index", status: :created
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
