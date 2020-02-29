# frozen_string_literal: true

require "rails_helper"

describe "api/v1/contributors/_show.json.jbuilder" do

  before(:each) do
    @data_contact = create(:contributor, org: build(:org))
    @ident = create(:identifier, identifiable: @data_contact,
                                 value: Faker::Lorem.word)
    @data_contact.reload
  end

  describe "includes all of the Contributor attributes" do
    before(:each) do
      render partial: "api/v1/contributors/show",
             locals: { contributor: @data_contact, role: :investigation }
      @json = JSON.parse(rendered).with_indifferent_access
    end

    it "includes the :name as `first last`" do
      expected = "#{@data_contact.firstname} #{@data_contact.surname}"
      expect(@json[:name]).to eql(expected)
    end
    it "includes the :mbox" do
      expect(@json[:mbox]).to eql(@data_contact.email)
    end

    it "includes the :role" do
      expect(@json[:role].end_with?("Investigation")).to eql(true)
    end

    it "includes :affiliations" do
      expect(@json[:affiliations].length).to eql(1)
    end

    it "includes :user_ids" do
      expect(@json[:contributor_ids].length).to eql(1)
    end
  end

  it "excludes the role if :role is nil" do
    render partial: "api/v1/contributors/show",
           locals: { contributor: @data_contact }
    json = JSON.parse(rendered).with_indifferent_access
    expect(json[:role]).to eql(nil)
  end

end