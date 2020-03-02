# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::PlanPresenter do

  describe "#initialize(plan:)" do
    before(:each) do
      plan = build(:plan)
      @data_contact = build(:contributor, writing_original_draft: true,
                                          data_curation: true)
      @pi = build(:contributor, investigation: true)
      plan.contributors = [@data_contact, @pi]
      @presenter = described_class.new(plan: plan)
    end

    it "sets contributors to empty array if no plan was specified" do
      presenter = described_class.new(plan: nil)
      expect(presenter.data_contact).to eql(nil)
      expect(presenter.contributors).to eql([])
    end
    it "sets contributors to empty array if plan has no contributors" do
      plan = build(:plan)
      plan.contributors = []
      presenter = described_class.new(plan: plan)
      expect(presenter.data_contact).to eql(nil)
      expect(presenter.contributors).to eql([])
    end
    it "sets data_contact" do
      expect(@presenter.data_contact).to eql(@data_contact)
    end
    it "sets other contributors (without the data_contact)" do
      expect(@presenter.contributors.length).to eql(1)
      expect(@presenter.contributors.first).to eql(@pi)
    end
  end

end
