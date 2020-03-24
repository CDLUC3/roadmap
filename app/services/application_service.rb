# frozen_string_literal: true

class ApplicationService

  class << self

    # Gets the default language
    def default_language
      lang = Language.where(default_language: true).first
      lang.present? ? lang.abbreviation : "en"
    end

    # Returns either the name specified in config/branding.yml or
    # the Rails application name
    def application_name
      # -------------------------------------
      # Start DMPTool Customization
      # removes our dash character for dev and stage envs

      # Rails.application.config.branding[:application]
      #   .fetch(:name, Rails.application.class.name.split('::').first).downcase

      name = Rails.application.config.branding[:application]
                  .fetch(:name, Rails.application.class.name.split('::').first)
      name.split("-").first.downcase
      # End DMPTool Customization
      # -------------------------------------
    end

  end

end
