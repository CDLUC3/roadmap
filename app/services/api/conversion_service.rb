# frozen_string_literal: true

module Api

  class ConversionService

    class << self

      # Converts a boolean field to [yes, no, unknown]
      def boolean_to_yes_no_unknown(value)
        return 'yes' if value == true || value == 1

        return 'no' if value == false || value == 0

        'unknown'
      end

      # Converts a [yes, no, unknown] field to boolean (or nil)
      def yes_no_unknown_to_boolean(value)
        return true if value == 'yes'

        return nil if value.blank? || value == 'unknown'

        false
      end

      # Converts the context and value into an Identifier with a psuedo
      # IdentifierScheme for display in JSON partials. Which will result in:
      #   { type: 'context', identifier: 'value' }
      def to_identifier(context:, value:)
        return nil unless value.present? && context.present?

        scheme = IdentifierScheme.new(name: context)
        Identifier.new(value: value, identifier_scheme: scheme)
      end

      # Gets the default language
      def default_language
        lang = Language.where(default_language: true).first
        lang.present? ? lang.abbreviation : "en"
      end

      # Returns either the name specified in config/branding.yml or
      # the Rails application name
      def application_name
        Rails.application.config.branding[:application]
          .fetch(:name, Rails.application.class.name.split('::').first).downcase
      end

    end

  end

end
