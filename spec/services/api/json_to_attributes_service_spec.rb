# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::JsonToAttributesService do

  describe "#identifier_from_json(json: {})" do
    before(:each) do
      @scheme = create(:identifier_scheme, user_landing_url: Faker::Internet.url)
    end

    it "returns nil when json[:identifier] is not present" do
      json = { type: Faker::Lorem.word }
      expect(described_class.identifier_from_json(json: json)).to eql(nil)
    end
    it "returns nil when json[:type] is not present" do
      json = { identifier: Faker::Lorem.word }
      expect(described_class.identifier_from_json(json: json)).to eql(nil)
    end
    it "returns nil if there is no matching IdentifierScheme" do
      json = { type: "foo", identifier: Faker::Lorem.word }
      expect(described_class.identifier_from_json(json: json)).to eql(nil)
    end
    it "returns the existing identifier" do
      id = create(:identifier, identifier_scheme: @scheme,
                               identifiable: create(:org))
      json = { type: @scheme.name.downcase, identifier: id.value }
      expect(described_class.identifier_from_json(json: json)).to eql(id)
    end
    it "initializes a new identifier" do
      json = { type: @scheme.name.downcase, identifier: Faker::Lorem.word }
      expected = described_class.identifier_from_json(json: json)
      expect(expected.new_record?).to eql(true)
    end
    it "strips out the IdentifierScheme user_landing_url from the value" do
      val = Faker::Lorem.word
      json = {
        type: @scheme.name.downcase,
        identifier: "#{@scheme.user_landing_url}#{val}"
      }
      expected = described_class.identifier_from_json(json: json)
      expect(expected.value).to eql(val)
    end
    it "sets the correct IdentifierScheme" do
      json = { type: @scheme.name.downcase, identifier: Faker::Lorem.word }
      result = described_class.identifier_from_json(json: json)
      expect(result.identifier_scheme).to eql(@scheme)
    end
    it "sets the value" do
      json = { type: @scheme.name.downcase, identifier: Faker::Lorem.word }
      result = described_class.identifier_from_json(json: json)
      expect(result.value).to eql(json[:identifier])
    end
  end

  describe "#org_from_json(json: {})" do
    before(:each) do
      @org = create(:org)
      @json = { name: Faker::Lorem.word }
    end

    it "returns nil when json[:name] sand json[:affiliation_ids] are not present" do
      expect(described_class.org_from_json(json: nil)).to eql(nil)
    end
    it "returns nil if the new org could not be initialized" do
      Org.stubs(:from_identifiers).returns(nil)
      described_class.stubs(:org_search_by_name).returns(nil)
      expect(described_class.org_from_json(json: @json)).to eql(nil)
    end
    it "returns the org when the Org is found by an identifier" do
      Org.stubs(:from_identifiers).returns(@org)
      described_class.expects(:org_search_by_name).at_most(0)
      expect(described_class.org_from_json(json: @json)).to eql(@org)
    end
    it "returns the org from the search service" do
      described_class.stubs(:org_search_by_name).returns(@org)
      expect(described_class.org_from_json(json: @json)).to eql(@org)
    end
    it "consolidates identifiers for the org" do
      described_class.stubs(:org_search_by_name).returns(@org)
      @org.expects(:consolidate_identifiers!).at_least(1)
      described_class.org_from_json(json: @json)
    end
    it "sets the name" do
      Org.stubs(:from_identifiers).returns(nil)
      described_class.stubs(:org_search_by_name).returns(@org)
      expect(described_class.org_from_json(json: @json).name).to eql(@org.name)
    end
  end

  describe "#contributor_from_json(json: {})" do
    before(:each) do
      @plan = create(:plan)
      @contributor = create(:contributor, plan: @plan, investigation: true)
      @json = { mbox: @contributor.email }
    end

    it "returns nil when json is not present" do
      result = described_class.contributor_from_json(plan: @plan, json: nil)
      expect(result).to eql(nil)
    end
    it "returns nil when json[:mbox] sand json[:surname] and ids are not present" do
      json = { firstname: Faker::Lorem.word }
      result = described_class.contributor_from_json(plan: @plan, json: json)
      expect(result).to eql(nil)
    end
    it "returns the contributor when the Contributor is found by an identifier" do
      Contributor.stubs(:from_identifiers).returns(@contributor)
      result = described_class.contributor_from_json(plan: @plan, json: @json)
      expect(result).to eql(@contributor)
    end
    it "returns the contributor when found by email" do
      result = described_class.contributor_from_json(plan: @plan, json: @json)
      expect(result).to eql(@contributor)
    end
    it "initializes a Contributor if one is not found by identifier or email" do
      json = { mbox: Faker::Internet.email }
      result = described_class.contributor_from_json(plan: @plan, json: json)
      expect(result.new_record?).to eql(true)
      expect(result.email).to eql(json[:mbox])
    end
    it "attaches the Org if an affiliation was in the json" do
      described_class.stubs(:org_from_json).returns(@contributor.org)
      Contributor.stubs(:from_identifiers).returns(@contributor)
      result = described_class.contributor_from_json(plan: @plan, json: @json)
      expect(result.org).to eql(@contributor.org)
    end
    it "sets the firstname" do
      json = { firstname: Faker::Lorem.word, mbox: Faker::Internet.email }
      result = described_class.contributor_from_json(plan: @plan, json: json)
      expect(result.firstname).to eql(json[:firstname])
    end
    it "sets the surname" do
      json = { firstname: Faker::Lorem.word, surname: Faker::Lorem.word }
      result = described_class.contributor_from_json(plan: @plan, json: json)
      expect(result.surname).to eql(json[:surname])
    end
    it "sets the email" do
      json = { mbox: Faker::Internet.email }
      result = described_class.contributor_from_json(plan: @plan, json: json)
      expect(result.email).to eql(json[:mbox])
    end
    it "adds the new role" do
      described_class.stubs(:contributor_from_json).returns(@contributor)
      result = described_class.contributor_from_json(plan: @plan, json: @json)
      expect(result.investigation?).to eql(true)
    end
  end

  describe "#plan_from_json(json: {})" do
    include Mocks::ApiJsonSamples

    before(:each) do
      create(:identifier_scheme, name: "grant")
      create(:template, is_default: true, published: true)
      @org = create(:org)
      described_class.stubs(:org_search_by_name).returns(@org)
      @plan = create(:plan)
      @json = JSON.parse(complete_create_json)["items"].first["dmp"]
    end

    it "returns nil when json is not present" do
      expect(described_class.plan_from_json(json: nil)).to eql(nil)
    end
    it "returns nil when json[:title] is not present" do
      @json[:title] = ""
      expect(described_class.plan_from_json(json: @json)).to eql(nil)
    end
    it "returns nil when json[:contact] is not present" do
      @json[:contact] = {}
      expect(described_class.plan_from_json(json: @json)).to eql(nil)
    end
    it "returns nil when json[:project] is not present" do
      @json[:project] = {}
      expect(described_class.plan_from_json(json: @json)).to eql(nil)
    end
    it "returns the plan when the Plan is found by its Plan.id" do
      @json["dmp_ids"] = [{
        type: ApplicationService.application_name,
        identifier: @plan.id
      }]
      expect(described_class.plan_from_json(json: @json)).to eql(@plan)
    end
    it "returns the plan when the Plan is found by an identifier" do
      Plan.stubs(:from_identifiers).returns(@plan)
      expect(described_class.plan_from_json(json: @json)).to eql(@plan)
    end
    it "attaches the Contributor if a contact was in the json" do
      result = described_class.plan_from_json(json: @json)
      contacts = result.contributors.select { |c| c.data_curation? }
      expect(contacts.length).to eql(1)
    end
    it "attaches the Contributors if they were in the json" do
      result = described_class.plan_from_json(json: @json)
      expect(result.contributors.length).to eql(2)
    end
    it "attaches the Funder if it was defined in the json" do
      result = described_class.plan_from_json(json: @json)
      expect(result.funder.present?).to eql(true)
    end
    it "attaches the Org if it was defined on the contact" do
      result = described_class.plan_from_json(json: @json)
      expect(result.org.present?).to eql(true)
    end
    it "attaches the Org if it was defined on the contact" do
      result = described_class.plan_from_json(json: @json)
      contacts = result.contributors.select { |c| c.data_curation? }
      expect(result.org).to eql(contacts.first.org)
    end
    it "attaches the Grant number if it was defined in the json" do
      result = described_class.plan_from_json(json: @json)
      expect(result.identifier_for_scheme(scheme: "grant").present?).to eql(true)
    end
    it "sets the template (for new plans)" do
      result = described_class.plan_from_json(json: @json)
      expect(result.template_id.present?).to eql(true)
    end
    it "sets the title" do
      result = described_class.plan_from_json(json: @json)
      expect(result.title.present?).to eql(true)
    end
    it "sets the description" do
      result = described_class.plan_from_json(json: @json)
      expect(result.description.present?).to eql(true)
    end
    it "sets the start_date" do
      result = described_class.plan_from_json(json: @json)
      expect(result.start_date.present?).to eql(true)
    end
    it "sets the end_date" do
      result = described_class.plan_from_json(json: @json)
      expect(result.end_date.present?).to eql(true)
    end
    it "sets the ethical_issues flag" do
      @json[:ethical_issues_exist] = "Yes"
      result = described_class.plan_from_json(json: @json)
      expect(result.ethical_issues?).to eql(true)
    end
    it "sets the ethical_issues_description" do
      result = described_class.plan_from_json(json: @json)
      expect(result.ethical_issues_description.present?).to eql(true)
    end
    it "sets the ethical_issues_report" do
      result = described_class.plan_from_json(json: @json)
      expect(result.ethical_issues_report.present?).to eql(true)
    end
  end

end
