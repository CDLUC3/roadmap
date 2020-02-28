# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::PlansController, type: :request do

  include ApiHelper

  context "ApiClient" do

    before(:each) do
      mock_authorization_for_api_client
    end

    describe "GET /api/v1/plan/:id - show" do
      it "returns the plan" do
        plan = create(:plan)
        get api_v1_plan_path(plan)
        expect(response.code).to eql("200")
        expect(response).to render_template("api/v1/plans/index")
        expect(assigns(:items).length).to eql(1)
      end
      it "returns a 404 if not found" do
        get api_v1_plan_path(9999)
        expect(response.code).to eql("404")
        expect(response).to render_template("api/v1/error")
      end
    end

    describe "POST /api/v1/plans - create" do
      include Webmocks
      include Mocks::ApiJsonSamples

      before(:each) do
        stub_ror_service
        mock_identifier_schemes

        create(:template, is_default: true, published: true)
        @json = JSON.parse(complete_create_json).with_indifferent_access
      end

      it "returns a 400 if the incoming JSON is invalid" do
        post api_v1_plans_path, Faker::Lorem.word
        expect(response.code).to eql("400")
        expect(response).to render_template("api/v1/error")
      end
      it "returns a 400 if the incoming DMP is invalid" do
        plan = create(:plan)
        @json[:items].first[:dmp][:title] = ""
        post api_v1_plans_path, @json.to_json
        expect(response.code).to eql("400")
        expect(response).to render_template("api/v1/error")
      end
      it "returns a 400 if the plan already exists" do
        plan = create(:plan)
        @json[:items].first[:dmp][:dmp_ids] = [{
          type: ApplicationService.application_name,
          identifier: plan.id
        }]
        post api_v1_plans_path, @json.to_json
        expect(response.code).to eql("400")
        expect(response).to render_template("api/v1/error")
        expect(response.body.include?("already exists")).to eql(true)
      end
      it "returns a 200 if the incoming JSON is valid" do
        post api_v1_plans_path, @json.to_json

p response.body

        expect(response.code).to eql("200")
        expect(response).to render_template("api/v1/plans/index")
      end
    end
  end

  context "User" do

    before(:each) do
      mock_authorization_for_user
    end

    describe "GET /api/v1/plan/:id - show" do
      it "returns the plan" do
        plan = create(:plan, org: Org.last)
        get api_v1_plan_path(plan)
        expect(response.code).to eql("200")
        expect(response).to render_template("api/v1/plans/index")
        expect(assigns(:items).length).to eql(1)
      end
      it "returns a 404 if not found" do
        get api_v1_plan_path(9999)
        expect(response.code).to eql("404")
        expect(response).to render_template("api/v1/error")
      end
      it "returns a 404 if the user does not have access" do
        user_org = Org.last
        org2 = create(:org)
        plan = create(:plan, org: org2)
        get api_v1_plan_path(plan)
        expect(response.code).to eql("404")
        expect(response).to render_template("api/v1/error")
      end
    end

  end

end
