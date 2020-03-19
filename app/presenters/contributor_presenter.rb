# frozen_string_literal: true

class ContributorPresenter

  class << self

    # Returns the name with each word capitalized
    def display_name(name:)
      return "" unless name.present?

      name.split.map { |part| part.capitalize }.join(" ")
    end

    # Returns the string name for each role
    def display_roles(roles:)
      return "None" unless roles.present? && roles.any?

      roles.map { |role| role_symbol_to_string(symbol: role) }.join("<br/>").html_safe
    end

    # Fetches the contributor's ORCID or initializes one
    def orcid(contributor:)
      orcid = contributor.identifier_for_scheme(scheme: "orcid")
      return orcid if orcid.present?

      scheme = IdentifierScheme.by_name("orcid").first
      return nil unless scheme.present?

      Identifier.new(identifiable: contributor, identifier_scheme: scheme)
    end

    def roles_for_radio(contributor:)
      all_roles = Contributor.new.all_roles
      return all_roles unless contributor.present?

      selected = contributor.selected_roles
      all_roles.map { |role| { "#{role}": selected.include?(role) } }
    end

    def role_symbol_to_string(symbol:)
      symbol.to_s.capitalize.gsub("_", " ")
    end

  end

end
