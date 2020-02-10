# frozen_string_literal: true

require "rails_helper"

describe "api/v1/orgs/_show.json.jbuilder" do

  before(:each) do
    scheme = create(:identifier_scheme)
    @org = create(:org)
    create(:identifier, value: Faker::Lorem.word, identifiable: @org,
                        identifier_scheme: scheme)
    @org.reload
    render partial: "api/v1/orgs/show", locals: { org: @org }
    @json = JSON.parse(rendered).with_indifferent_access
  end

  describe "includes all of the org attributes" do
    it "includes :name" do
      expect(@json[:name]).to eql(@org.name)
    end
    it "includes :abbreviation" do
      expect(@json[:abbreviation]).to eql(@org.abbreviation)
    end
    it "includes :region" do
      expect(@json[:region]).to eql(@org.region.abbreviation)
    end
    it "includes :affiliation_ids" do
      expect(@json[:affiliation_ids].length).to eql(1)
    end
  end

end
