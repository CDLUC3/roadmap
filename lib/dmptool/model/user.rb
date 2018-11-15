# frozen_string_literal: true

module Dmptool::Model::User

  extend ActiveSupport::Concern

  class_methods do
    # Load the user based on the scheme and id provided by the Omniauth call
    def from_omniauth(auth)
      scheme = IdentifierScheme.find_by(name: auth.provider.downcase)

      if scheme.nil?
        throw Exception.new("Unknown OAuth provider: %{provider}" % {
          provider: auth.provider
        })
      else
        joins(:user_identifiers).where(
          "user_identifiers.identifier": auth.uid.downcase,
          "user_identifiers.identifier_scheme_id": scheme.id
        ).first
      end
    end
  end

  included do
    # LDap Users password reset
    def valid_password?(password)
      if !has_devise_password? && ldap_password?
        if verify_legacy_password(ldap_password, password)
          convert_password_to_devise(password)
        else
          return false
        end
      end

      super
    end

    def has_devise_password?
      encrypted_password.present?
    end

    def ldap_password?
      ldap_password.present?
    end

    def verify_legacy_password(ldap_password, password)
      # LDAP encoding, a 20-byte binary SHA-1 hash and an 8-byte binary
      # salt are concatenated, Base64-encoded, and prepended with "{SSHA}".
      # Base64Encode(SHA1(password+salt)+salt)
      str = ldap_password.sub("{SSHA}", '')
      base64_decoded_hash = Base64.decode64(str)
      if base64_decoded_hash.length == 28
        sha1_hash = base64_decoded_hash[0, base64_decoded_hash.length - 8] #SHA1(password+salt)
        salt = base64_decoded_hash.split(//).last(8).join
      end
      # Generate the Ldap hash using user entered password and above salt for password verification
      hash_to_verify = '{SSHA}' + Base64.encode64(Digest::SHA1.digest(password + salt) + salt).chomp!
      return true if hash_to_verify.strip == ldap_password.strip
      false
    end

    def convert_password_to_devise(password)
      self.password = password
      self.ldap_password = nil
      self.save!
    end
  end

end
