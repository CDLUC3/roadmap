# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identifier, type: :model do

  context "validations" do
    it { is_expected.to validate_presence_of(:value) }

    it { is_expected.to validate_presence_of(:identifiable) }
  end

  context "associations" do
    it { is_expected.to belong_to(:identifiable) }

    it { is_expected.to belong_to(:identifier_scheme) }
  end

  context "scopes" do
    describe "#by_scheme_name" do
      before(:each) do
        @scheme = create(:identifier_scheme)
        @scheme2 = create(:identifier_scheme)
        @id = create(:identifier, :for_plan, identifier_scheme: @scheme)
        @id2 = create(:identifier, :for_plan, identifier_scheme: @scheme2)

        @rslts = described_class.by_scheme_name(@scheme.name, "Plan")
      end

      it "returns the correct identifier" do
        expect(@rslts.include?(@id)).to eql(true)
      end
      it "does not return the identifier for the other scheme" do
        expect(@rslts.include?(@id2)).to eql(false)
      end
    end
  end

  describe "#attrs=" do
    let!(:identifier) { create(:identifier) }

    it "when hash is a Hash sets attrs to a String of JSON" do
      identifier.attrs = { foo: "bar" }
      expect(identifier.attrs).to eql({ "foo": "bar" }.to_json)
    end

    it "when hash is nil sets attrs to empty JSON object" do
      identifier.attrs = nil
      expect(identifier.attrs).to eql({}.to_json)
    end

    it "when hash is a String sets attrs to empty JSON object" do
      identifier.attrs = ""
      expect(identifier.attrs).to eql({}.to_json)
    end
  end

  describe "#identifier_format" do
    it "returns 'orcid' for identifiers associated with the orcid identifier_scheme" do
      scheme = build(:identifier_scheme, name: "orcid")
      id = build(:identifier, identifier_scheme: scheme)
      expect(id.identifier_format).to eql("orcid")
    end
    it "returns 'ror' for identifiers associated with the ror identifier_scheme" do
      scheme = build(:identifier_scheme, name: "ror")
      id = build(:identifier, identifier_scheme: scheme)
      expect(id.identifier_format).to eql("ror")
    end
    it "returns 'fundref' for identifiers associated with the fundref identifier_scheme" do
      scheme = build(:identifier_scheme, name: "fundref")
      id = build(:identifier, identifier_scheme: scheme)
      expect(id.identifier_format).to eql("fundref")
    end
    it "returns 'ark' for identifiers whose value contains 'ark:'" do
      scheme = build(:identifier_scheme, name: "ror")
      val = "#{scheme.identifier_prefix}ark:#{Faker::Lorem.word}"
      id = create(:identifier, value: val)
      expect(id.identifier_format).to eql("ark")
    end
    it "returns 'doi' for identifiers whose value matches the doi format" do
      scheme = build(:identifier_scheme, name: "ror")
      val = "#{scheme.identifier_prefix}doi:10.1234/123abc98"
      id = create(:identifier, value: val)
      expect(id.identifier_format).to eql("doi"), "expected url containing 'doi:' to be a doi"

      val = "#{scheme.identifier_prefix}10.1234/123abc98"
      id = create(:identifier, value: val)
      expect(id.identifier_format).to eql("doi"), "expected url not containing 'doi:' to be a doi"
    end
    it "returns 'url' for identifiers whose value matches a URL format" do
      scheme = build(:identifier_scheme, name: "ror")
      id = create(:identifier, value: "#{scheme.identifier_prefix}#{Faker::Lorem.word}")
      expect(id.identifier_format).to eql("url")

      id = create(:identifier, value: "#{scheme.identifier_prefix}#{Faker::Lorem.word}")
      expect(id.identifier_format).to eql("url")
    end
    it "returns 'other' for all other identifier values" do
      id = create(:identifier, value: Faker::Lorem.word)
      expect(id.identifier_format).to eql("other"), "expected alpha characters to return 'other'"

      id = create(:identifier, value: Faker::Number.number)
      expect(id.identifier_format).to eql("other"), "expected numeric characters to return 'other'"

      id = create(:identifier, value: SecureRandom.uuid)
      expect(id.identifier_format).to eql("other"), "expected UUID to return 'other'"
    end
  end

end
