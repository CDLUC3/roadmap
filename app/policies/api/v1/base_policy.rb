# frozen_string_literal: true

module Api

  module V1

    class BasePolicy < ApplicationPolicy

      def authorize(client:, context:)
        raise_not_authorized(msg: _("must be logged in")) unless client.present?

        # If the client is a User then authorize the User
        return auth_user(user: client, context: context) if client.is_a?(User)

        # Otherwise its an API client
        auth_api_client
      end

      # Raises a Pundit error with the specified message
      def raise_not_authorized(msg:)
        raise Pundit::NotAuthorizedError, message
      end

      private

      def auth_user(user:, context:)
        return false unless user.org.present? && context.present?

        type = context.class.name.underscore.pluralize.upcase
        return false unless type.present?

        # If the Usser's Org allows permission to the context
        token_type = "TokenPermissionType::#{type}".constantize

p token_type

        return false unless user.org.token_permission_types.include?(token_type)
      end

      def auth_api_client(api_client:)
        # ??? Not sure where or when to use this yet
        true
      end

    end

  end

end
