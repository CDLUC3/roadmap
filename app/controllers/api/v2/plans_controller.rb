# frozen_string_literal: true

module Api

  module V2

    class PlansController < BaseApiController

      include ::ConditionsHelper

      respond_to :json, :pdf

      # If the Resource Owner (aka User) is in the Doorkeeper AccessToken then it is an authorization_code
      # token and we need to ensure that the ApiClient is authorized for the relevant Scope
      before_action -> { doorkeeper_authorize!(:read_dmps) if @resource_owner.present? }, only: %i[index show]
      before_action -> { doorkeeper_authorize!(:create_dmps) if @resource_owner.present? }, only: %i[create]

      # GET /api/v2/plans
      # -----------------
      def index
        @scope = "mine"
        @scope = params[:scope].to_s.downcase if %w[mine public both].include?(params[:scope].to_s.downcase)

        # See the Policy for details on what Plans are returned to the Caller based on the AccessToken
        plans = Api::V2::PlansPolicy::Scope.new(@client, @resource_owner, @scope).resolve

        if plans.present? && plans.any?
          plans = plans.sort { |a, b| b.updated_at <=> a.updated_at }
          @items = paginate_response(results: plans)
          @minimal = true
          render "api/v2/plans/index", status: :ok
        else
          render_error(errors: [_("No Plans found")], status: :not_found)
        end
      end

      # GET /api/v2/plans/:id
      # ---------------------
      def show
        # See the Policy for details on what Plans are returned to the Caller based on the AccessToken
        @plan = Api::V2::PlansPolicy::Scope.new(@client, @resource_owner, nil).resolve
                                           .select { |plan| plan.id = params[:id] }.first

        if @plan.present?
          respond_to do |format|
            format.pdf do
              prep_for_pdf

              render pdf: @file_name,
                     margin: @formatting[:margin],
                     footer: {
                       center: _("Created using %{application_name}. Last modified %{date}") % {
                         application_name: ApplicationService.application_name,
                         date: l(@plan.updated_at.to_date, format: :readable)
                       },
                       font_size: 8,
                       spacing: (Integer(@formatting[:margin][:bottom]) / 2) - 4,
                       right: "[page] of [topage]",
                       encoding: "utf8"
                     }
            end

            format.json do
              @items = paginate_response(results: [@plan])
              render "/api/v2/plans/index", status: :ok
            end
          end
        else
          render_error(errors: [_("Plan not found")], status: :not_found)
        end
      end

      # POST /api/v2/plans
      # ------------------
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def create
        dmp = @json.with_indifferent_access.fetch(:dmp, {})

        # Do a pass through the raw JSON and check to make sure all required fields
        # were present. If not, return the specific errors
        errs = Api::V1::JsonValidationService.validation_errors(json: dmp)
        render_error(errors: errs, status: :bad_request) and return if errs.any?

        # Convert the JSON into a Plan and it's associations
        plan = Api::V1::Deserialization::Plan.deserialize(json: dmp)
        if plan.present?
          save_err = _("Unable to create your DMP")
          exists_err = _("Plan already exists. Send an update instead.")
          no_org_err = _("Could not determine ownership of the DMP. Please add an
                          :affiliation to the :contact")

          # Try to determine the Plan's owner
          owner = determine_owner(client: client, plan: plan)
          plan.org = owner.org if owner.present? && plan.org.blank?
          render_error(errors: no_org_err, status: :bad_request) and return unless plan.org.present?

          # Validate the plan and it's associations and return errors with context
          # e.g. 'Contact affiliation name can't be blank' instead of 'name can't be blank'
          errs = Api::V1::ContextualErrorService.process_plan_errors(plan: plan)

          # The resulting plan (our its associations were invalid)
          render_error(errors: errs, status: :bad_request) and return if errs.any?
          # Skip if this is an existing DMP
          render_error(errors: exists_err, status: :bad_request) and return unless plan.new_record?

          # If we cannot save for some reason then return an error
          plan = Api::V1::PersistenceService.safe_save(plan: plan)
          # rubocop:disable Layout/LineLength
          render_error(errors: save_err, status: :internal_server_error) and return if plan.new_record?

          # rubocop:enable Layout/LineLength

pp dmp
p "---------------------"
pp dmp[:dmp_id]

          # If the plan was generated by an ApiClient then add a subscription for them
          dmp_id_to_subscription(plan: plan, id_json: dmp[:dmp_id]) if client.is_a?(ApiClient)

          # Invite the Owner if they are a Contributor then attach the Owner to the Plan
          owner = invite_contributor(contributor: owner) if owner.is_a?(Contributor)
          plan.add_user!(owner.id, :creator)

          # Kaminari Pagination requires an ActiveRecord result set :/
          @items = paginate_response(results: Plan.where(id: plan.id))
          render "/api/v2/plans/index", status: :created
        else
          render_error(errors: [_("Invalid JSON!")], status: :bad_request)
        end
      rescue JSON::ParserError
        render_error(errors: [_("Invalid JSON")], status: :bad_request)
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      private

      def dmp_params
        params.require(:dmp).permit(plan_permitted_params).to_h
      end

      def plan_exists?(json:)
        return false unless json.present? &&
                            json[:dmp_id].present? &&
                            json[:dmp_id][:identifier].present?

        scheme = IdentifierScheme.by_name(json[:dmp_id][:type]).first
        Identifier.where(value: json[:dmp_id][:identifier], identifier_scheme: scheme).any?
      end

      # Get the Plan's owner
      def determine_owner(client:, plan:)
        contact = plan.contributors.select(&:data_curation?).first
        # Use the contact if it was sent in and has an affiliation defined
        return contact if contact.present? && contact.org.present?

        # If the contact has no affiliation defined, see if they are already a User
        user = lookup_user(contributor: contact)
        return user if user.present?

        # Otherwise just return the client
        client
      end

      def lookup_user(contributor:)
        return nil unless contributor.present?

        identifiers = contributor.identifiers.map do |id|
          { name: id.identifier_scheme&.name, value: id.value }
        end
        user = User.from_identifiers(array: identifiers) if identifiers.any?
        user = User.find_by(email: contributor.email) unless user.present?
        user
      end

      def invite_contributor(contributor:)
        return nil unless contributor.present?

        # If the user was not found, invite them and attach any know identifiers
        names = contributor.name&.split || [""]
        firstname = names.length > 1 ? names.first : nil
        surname = names.length > 1 ? names.last : names.first
        user = User.invite!({ email: contributor.email,
                              firstname: firstname,
                              surname: surname,
                              org: contributor.org }, client)

        user = User.create({ email: contributor.email, firstname: firstname,
                             surname: surname, org: contributor.org,
                             password: SecureRandom.uuid })
        contributor.identifiers.each do |id|
          user.identifiers << Identifier.new(
            identifier_scheme: id.identifier_scheme, value: id.value
          )
        end
        user
      end

      # Convert the dmp_id into an identifier for the ApiClient if applicable
      def dmp_id_to_subscription(plan:, id_json:)
        return nil unless id_json.is_a?(Hash) && id_json[:type] == "other" && @client.is_a?(ApiClient)

        val = id_json[:identifier] if id_json[:identifier].start_with?(@client.callback_uri || "")
        val = "#{@client.callback_uri}#{id_json[:identifier]}" unless val.present?

        subscription = Subscription.find_or_initialize_by(
          plan: plan,
          subscriber: @client,
          callback_uri: val
        )
        subscription.updates = true
        subscription.deletions = true
        subscription.save
      end

      def prep_for_pdf
        return false unless @plan.present?

        # We need to eager loadd the plan to make this more efficient
        @plan = Plan.includes(:org, :research_outputs, roles: [:user],
                              contributors: [:org, identifiers: [:identifier_scheme]],
                              identifiers: [:identifier_scheme])
                    .find_by(id: @plan.id)

        # Include everything by default
        @show_coversheet         = true
        @show_sections_questions = true
        @show_unanswered         = true
        @show_custom_sections    = true
        @show_research_outputs   = @plan.research_outputs.any?
        @public_plan             = @plan.publicly_visible?
        @formatting =

        @hash           = @plan.as_pdf(@show_coversheet)
        @formatting     = @plan.settings(:export).formatting || @plan.template.settings(:export).formatting
        @selected_phase = @plan.phases.order("phases.updated_at DESC")

        # limit the filename length to 100 chars. Windows systems have a MAX_PATH allowance
        # of 255 characters, so this should provide enough of the title to allow the user
        # to understand which DMP it is and still allow for the file to be saved to a deeply
        # nested directory
        @file_name = Zaru.sanitize!(@plan.title).strip.gsub(/\s+/, "_")[0, 100]
      end
    end

  end

end
