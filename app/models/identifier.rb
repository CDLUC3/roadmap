# frozen_string_literal: true

# == Schema Information
#
# Table name: identifiers
#
#  id                   :integer          not null, primary key
#  attrs                :text
#  identifiable_type    :string
#  value                :string           not null
#  created_at           :datetime
#  updated_at           :datetime
#  identifiable_id      :integer
#  identifier_scheme_id :integer          not null
#
# Indexes
#
#  index_identifiers_on_identifiable_type_and_identifiable_id  (identifiable_type,identifiable_id)
#
class Identifier < ActiveRecord::Base

  include ValidationMessages

  # ================
  # = Associations =
  # ================

  belongs_to :identifiable, polymorphic: true

  belongs_to :identifier_scheme

  # ===============
  # = Validations =
  # ===============

  # TODO: This doesn't seem to work for a polymorphic relationship :/
  # validates :identifier_scheme,
  #          presence: { message: PRESENCE_MESSAGE },
  #          uniqueness: { scope: %i[identifiable_id identifiable_type],
  #                        message: UNIQUENESS_MESSAGE }

  validates :value, presence: { message: PRESENCE_MESSAGE }

  validates :identifiable, presence: { message: PRESENCE_MESSAGE }

  # ===============
  # = Scopes =
  # ===============
  def self.by_scheme_name(value, identifiable_type)
    where(identifier_scheme: IdentifierScheme.by_name(value),
          identifiable_type: identifiable_type)
  end

  # ===========================
  # = Public instance methods =
  # ===========================
  def attrs=(hash)
    write_attribute(:attrs, (hash.is_a?(Hash) ? hash.to_json.to_s : "{}"))
  end

  # ========================
  # = JSON helpers for API =
  # ========================
  def self.from_json(json:)
    json = json.with_indifferent_access

    # get the IdentifierScheme
    scheme = IdentifierScheme.by_name(json[:type].downcase).first
    return nil unless scheme.present?

    Identifier.find_or_initialize_by(
      identifier_scheme: scheme,
      value: url_to_value(val: json[:identifier])
    )

  rescue JSON::ParserError => pe
    Rails.logger.error "JSON parse error in Identifier.from_json: #{pe.message}"
    Rails.logger.error json.inspect
    return nil
  end

  def to_json
    val =
    {
      type: identifier_scheme.name,
      identifier: value_to_url
    }.to_json
  end

  # Append the scheme's langing page URL if applicable
  def value_to_url
    landing = scheme.user_landing_url&.downcase
    landing.present? ? "#{landing}#{value}" : value
  end

  # Extract the landing page URL for the scheme
  def url_to_value(val:)
    landing = scheme.user_landing_url&.downcase
    value = landing.present? ? val.to_s.downcase.gsub(landing, "") : val
  end

end
