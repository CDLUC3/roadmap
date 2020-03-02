# frozen_string_literal: true

module Dmptool

  module Model

    module Org

      extend ActiveSupport::Concern

      class_methods do
        # DMPTool participating institution helpers
        def participating
          self.includes(identifiers: :identifier_scheme)
              .where(is_other: false)
        end
      end

      included do
        def shibbolized?
          Identifier.by_scheme_name("shibboleth", "Org").map { |id| id.identifiable }
        end
      end

    end

  end

end
