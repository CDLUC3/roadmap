# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::PlansContributorPresenter do

  describe "#role_as_uri" do
    it "returns nil if the plans_contributor role is nil" do
      uri = described_class.role_as_uri(role: nil)
      expect(uri).to eql(nil)
    end
    it "returns the correct URI" do
      uri = described_class.role_as_uri(role: "data_curation")
      expect(uri.start_with?("http")).to eql(true)
      expect(uri.end_with?("Data_curation")).to eql(true)
    end
  end

end
