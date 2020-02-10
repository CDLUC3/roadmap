# frozen_string_literal: true

require "rails_helper"

describe "api/v1/plans/_show.json.jbuilder" do

  before(:each) do
    @plan = create(:plan, ethical_issues: true)
    @data_contact = create(:contributor)
    @pi = create(:contributor)
    @plan.plans_contributors = [
      create(:plans_contributor, contributor: @data_contact, data_curation: true,
                                 writing_original_draft: true),
      create(:plans_contributor, contributor: @pi, investigation: true)

    ]
    create(:identifier, identifiable: @plan)
    @plan.reload
  end

  describe "includes all of the DMP attributes" do

    before(:each) do
      render partial: "api/v1/plans/show", locals: { plan: @plan }
      @json = JSON.parse(rendered).with_indifferent_access
    end

    it "includes the :title" do
      expect(@json[:title]).to eql(@plan.title)
    end
    it "includes the :description" do
      expect(@json[:description]).to eql(@plan.description)
    end
    it "includes the :language" do
      expected = Api::ConversionService.default_language
      expect(@json[:language]).to eql(expected)
    end
    it "includes the :created" do
      expect(@json[:created]).to eql(@plan.created_at.utc.to_s)
    end
    it "includes the :modified" do
      expect(@json[:modified]).to eql(@plan.updated_at.utc.to_s)
    end
    it "includes the :ethical_issues_exist" do
      expect(@json[:ethical_issues_exist]).to eql("yes")
    end
    it "includes the :ethical_issues_description" do
      expect(@json[:ethical_issues_description]).to eql(
        @plan.ethical_issues_description)
    end
    it "includes the :ethical_issues_report" do
      expect(@json[:ethical_issues_report]).to eql(@plan.ethical_issues_report)
    end

    it "includes the :identifiers" do
      expected = @plan.identifiers.first.value
      expect(@json[:dmp_ids].first[:identifier].end_with?(expected)).to eql(true)
    end

    it "includes the :contact" do
      expect(@json[:contact][:mbox]).to eql(@data_contact.email)
    end
    it "includes the :contributors" do
      expect(@json[:contributors].first[:mbox]).to eql(@pi.email)
    end

    # TODO: make sure this is working once the new Cost theme and Currency
    #       question type have been implemented
    it "includes the :costs" do
      expect(@json[:costs]).to eql(nil)
    end
  end

end