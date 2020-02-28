# frozen_string_literal: true

# locals: plan

presenter = Api::PlanPresenter.new(plan: plan)
# A JSON representation of a Data Management Plan in the
# RDA Common Standard format
json.title plan.title
json.description plan.description
json.language ApplicationService.default_language
json.created plan.created_at.utc.to_s
json.modified plan.updated_at.utc.to_s

json.ethical_issues_exist Api::ConversionService.boolean_to_yes_no_unknown(
  plan.ethical_issues
)
json.ethical_issues_description plan.ethical_issues_description
json.ethical_issues_report plan.ethical_issues_report

if plan.identifiers.any?
  json.dmp_ids plan.identifiers do |identifier|
    json.partial! 'api/v1/identifiers/show', identifier: identifier
  end
end

if presenter.data_contact.present?
  json.contact do
    json.partial! "api/v1/contributors/show", contributor: presenter.data_contact
  end
end

if presenter.contributors.any?
  json.contributors presenter.contributors do |plans_contributor|
    plans_contributor.selected_roles.each do |role|
      json.partial! "api/v1/contributors/show",
                    contributor: plans_contributor.contributor, role: role
    end
  end
end

if presenter.costs.any?
  json.costs presenter.costs do |cost|
    json.partial! 'api/v1/plans/cost', cost: cost
  end
end

json.project do
  json.partial! 'api/v1/plans/project', plan: plan
end

#json.datasets plan.datasets do |dataset|
#  json.partial! 'api/v1/datasets/show', dataset: dataset
#end
