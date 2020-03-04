# frozen_string_literal: true

module Dmptool

  module Models

    module Org

      extend ActiveSupport::Concern

      class_methods do

        # DMPTool participating institution helpers
        def participating
          self.includes(identifiers: :identifier_scheme)
              .where(is_other: false).order(:name)
        end

      end

      included do

        def shibbolized?
          shib_scheme = IdentifierScheme.by_name("shibboleth")

          identifiers.select { |id| id.identifier_scheme == shib_scheme }.any?
        end

      end

    end

  end

end
