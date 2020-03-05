# frozen_string_literal: true

module Api

  module V1

    # Accepts 2 types of authentication:
    #
    # Client Credentials:
    #  * NOTE: requires an entry in the `api_clients` table
    #
    #  POST Body must include the following JSON: {
    #    grant_type: "client_credentials",
    #    client_id: "[api_client.client_id]",
    #    client_secret: "[api_client.client_secret]"
    #  }
    #
    # Authorization Code:
    #  * NOTE: requires a `users.api_token` and User must have permission!
    #
    #  POST Body must includethe following JSON: {
    #    grant_type: "authorization_code",
    #    email: "[users.email]",
    #    code: "[users.api_token]"
    #  }
    class AuthenticationController < BaseApiController

      respond_to :json

      skip_before_action :authorize_request, only: %i[authenticate]

      # POST /api/v1/authenticate
      def authenticate

p "BODY"
p request.body.read
p "PARAMS"
p params

        json = JSON.parse(request.body.read)
        auth_svc = Api::Auth::Jwt::AuthenticationService.new(json: json)
        @token = auth_svc.call

        if @token.present?
          @expiration = auth_svc.expiration
          @token_type = "Bearer"
          render "/api/v1/token", status: :ok
        else
          render_error errors: auth_svc.errors, status: :unauthorized
        end

      rescue JSON::ParserError => pe
        Rails.logger.error "API V1 - authenticate: #{pe.message}"
        Rails.logger.error request.body.read
        render_error errors: _("Missing or invalid JSON"), status: :bad_request
      end

    end

  end

end
