# frozen_string_literal: true

# locals: contributor, role

role = role || nil

json.name contributor.name
json.mbox contributor.email
json.role Api::ContributorPresenter.role_as_uri(role: role) if role.present?

if contributor.org.present?
  json.affiliations [contributor.org] do |org|
    json.partial! "api/v1/orgs/show", locals: { org: org }
  end
end

if contributor.identifiers.any?
  json.contributor_ids contributor.identifiers do |identifier|
    json.partial! "api/v1/identifiers/show", locals: { identifier: identifier }
  end
end
