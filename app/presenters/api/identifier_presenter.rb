# frozen_string_literal: true

module Api

  class IdentifierPresenter

    def initialize(identifier:)
      @id = identifier
    end

    def identifier
      return nil unless @id.present? && @id.identifier_scheme.name != "shibboleth"

      landing_url = @id.identifier_scheme&.user_landing_url
      return @id.value unless landing_url.present?

      "#{landing_url}#{@id.value}"
    end

  end

end
