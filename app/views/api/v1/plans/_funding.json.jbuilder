# frozen_string_literal: true

# locals: plan

json.name plan.funder.name
json.funding_status Api::FundingPresenter.status(plan: plan)

if plan.funder.identifiers.any?
  json.funder_ids plan.funder.identifiers do |identifier|
    json.partial! "api/v1/identifiers/show", identifier: identifier
  end
end

if plan.grant_number.present?
  grant = Api::ConversionService.to_identifier(context: "grant",
                                               value: plan.grant_number)
  json.grant_ids [grant] do |grant|
    json.partial! "api/v1/identifiers/show", identifier: grant
  end
end
