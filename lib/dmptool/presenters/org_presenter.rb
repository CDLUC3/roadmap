# frozen_string_literal: true


module Dmptool

  module Presenters

    class OrgPresenter

      include Rails.application.routes.url_helpers

      def initialize
        @shib = IdentifierScheme.by_name("shibboleth").first
      end

      def participating_orgs
        Org.participating.order(:name)
      end

      def sign_in_url(org:)
        return nil unless org.present? && @shib.present?

        return org_logo_path(org) unless org.identifiers.any?

        # If the org does not have a Shib entityId registered
        entity_id = org.identifiers.select { |id| id.identifier_scheme_id == @shib.id }
        return org_logo_path(org) unless entity_id.any?

        shibbolized_url(org: org)
      end

      def shibbolized_url(org:)
        return nil unless org.present?

        # qs = "shib-ds[org_name=#{org.id}]&shib-ds[org_id=#{org.id}]"
        # "#{shibboleth_ds_path}/#{org.id}?#{qs}]"
        query_string = "org[id=#{org.id}]"
        "#{shibboleth_ds_path}/#{org.id}?#{query_string}"
      end

    end

  end

end
