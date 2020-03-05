# frozen_string_literal: true

# locals: plan

json.name plan.funder.name

if plan.funder.identifiers.any?
  json.funder_ids plan.funder.identifiers do |identifier|
    json.partial! "api/v1/identifiers/show", identifier: identifier
  end
end

grant_ids = plan.identifiers.select { |id| id.identifier_scheme.name == "grant" }
grant_ids = [plan.grant_number] if grant_ids.empty? && plan.grant_number.present?
if grant_ids.any?
  json.grant_ids grant_ids do |identifier|
    json.partial! 'api/v1/identifiers/show', identifier: identifier
  end
end
json.funding_status grant_ids.empty? ? "planned" : "granted"