# frozen_string_literal: true

require "rails_helper"

describe "api/v1/plans/_funding.json.jbuilder" do

  before(:each) do
    @funder = create(:org, :funder)
    create(:identifier, identifiable: @funder,
                        identifier_scheme: create(:identifier_scheme))
    @funder.reload
    @plan = build(:plan, funder: @funder)

    render partial: "api/v1/plans/funding", locals: { plan: @plan }
    @json = JSON.parse(rendered).with_indifferent_access
  end

  describe "includes all of the funding attributes" do
    it "includes :name" do
      expect(@json[:name]).to eql(@funder.name)
    end
    it "includes :funding_status" do
      expected = Api::FundingPresenter.status(plan: @plan)
      expect(@json[:funding_status]).to eql(expected)
    end
    it "includes :funder_ids" do
      expect(@json[:funder_ids].length).to eql(1)
    end
    it "includes :grant_ids" do
      expect(@json[:grant_ids].length).to eql(1)
    end
  end

end
