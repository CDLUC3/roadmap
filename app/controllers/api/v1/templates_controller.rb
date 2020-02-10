# frozen_string_literal: true

module Api

  module V1

    class TemplatesController < BaseApiController

      respond_to :json

      # GET /api/v1/templates
      def index
        templates = Template.includes(org: :identifiers).joins(:org)
                            .published.where(customization_of: nil).order(:title)

        @items = paginate_response(results: templates)
        render "/api/v1/templates/index", status: :ok
      end

    end

  end

end
