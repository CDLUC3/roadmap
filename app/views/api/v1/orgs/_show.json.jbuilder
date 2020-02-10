# frozen_string_literal: true

# locals: org

json.name org.name
json.abbreviation org.abbreviation
json.region org.region&.abbreviation

if org.identifiers.any?
  json.affiliation_ids org.identifiers do |identifier|
    # skip Org sibboleth identifiers
    next if identifier.identifier_scheme.name.downcase == "shibboleth"

    json.partial! "api/v1/identifiers/show", locals: { identifier: identifier }
  end
end
