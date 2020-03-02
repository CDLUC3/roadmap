# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::PlansController, type: :request do

  include ApiHelper

  context "ApiClient" do

    before(:each) do
      mock_authorization_for_api_client

      # Org model requires a language so make sure the default is set
      create(:language, default_language: true)
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
      end

      context "minimal JSON" do
        before(:each) do
          @json = JSON.parse(minimal_create_json).with_indifferent_access
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
          expect(response.code).to eql("200")
          expect(response).to render_template("api/v1/plans/index")
        end

        context "plan inspection" do
          before(:each) do
            post api_v1_plans_path, @json.to_json
            @original = @json.with_indifferent_access[:items].first[:dmp]
            @plan = Plan.last
          end

          it "set the Plan title" do
            expect(@plan.title).to eql(@original[:title])
          end
          it "attached the contact to the Plan" do
            expect(@plan.contributors.length).to eql(1)
          end
          it "set the Contact email" do
            expected = @plan.contributors.first.email
            expect(expected).to eql(@original[:contact][:mbox])
          end
          it "set the Contact roles" do
            expected = @plan.contributors.first
            expect(expected.data_curation?).to eql(true)
            expect(expected.writing_original_draft?).to eql(true)
          end
          it "set the Template id" do
            app = ApplicationService.application_name
            expected = @original[:extended_attributes][:"#{app}"][:template_id]
            expect(@plan.template_id).to eql(expected)
          end
        end
      end

      context "complete JSON" do
        before(:each) do
          @json = JSON.parse(complete_create_json).with_indifferent_access
        end

        it "returns a 200 if the incoming JSON is valid" do
          post api_v1_plans_path, @json.to_json
          expect(response.code).to eql("200")
          expect(response).to render_template("api/v1/plans/index")
        end

        context "plan inspection" do
          before(:each) do
            post api_v1_plans_path, @json.to_json
            @original = @json.with_indifferent_access[:items].first[:dmp]
            @plan = Plan.last
          end

          it "set the Plan title" do
            expect(@plan.title).to eql(@original[:title])
          end

          it "set the Plan description" do
            expect(@plan.title).to eql(@original[:title])
          end
          it "set the Plan ethical_issues flag" do
            expect(@plan.title).to eql(@original[:title])
          end
          it "set the Plan ethical_issues_description" do
            expect(@plan.title).to eql(@original[:title])
          end
          it "set the Plan ethical_issues_report" do
            expect(@plan.title).to eql(@original[:title])
          end
          it "set the Plan start_date" do
            expect(@plan.title).to eql(@original[:title])
          end
          it "set the Plan end_date" do
            expect(@plan.title).to eql(@original[:title])
          end
          it "Plan identifiers includes the grant id" do
            expect(@plan.identifiers.length).to eql(1)
            expected = @original[:project][:funding].first[:grant_ids].first[:type]
            expect(@plan.identifiers.first.identifier_scheme.name).to eql(expected)

            expected = @original[:project][:funding].first[:grant_ids].first[:identifier]
            expect(@plan.identifiers.first.value).to eql(expected)
          end

          context "contact inspection" do
            before(:each) do
              @original = @original[:contact]
              contacts = @plan.contributors.select do |pc|
                pc.email == @original[:mbox]
              end
              @contact = contacts.first
            end

            it "attached the Contact to the Plan" do
              expect(@contact.present?).to eql(true)
            end
            it "set the Contact firstname" do
              expect(@contact.firstname).to eql(@original[:firstname])
            end
            it "set the Contact surname" do
              expect(@contact.surname).to eql(@original[:surname])
            end
            it "set the Contact email" do
              expect(@contact.email).to eql(@original[:mbox])
            end
            it "set the Contact roles" do
              expect(@contact.data_curation?).to eql(true)
              expect(@contact.writing_original_draft?).to eql(true)
            end
            it "Contact identifiers includes the orcid" do
              expect(@contact.identifiers.length).to eql(1)
              expected = @original[:contributor_ids].first[:type]
              expect(@contact.identifiers.first.identifier_scheme.name).to eql(expected)

              expected = @original[:contributor_ids].first[:identifier]
              expect(@contact.identifiers.first.value).to eql(expected)
            end
            it "ignored the unknown identifier type" do
              results = @contact.identifiers.select do |i|
                i.value == @original[:contributor_ids].last
              end
              expect(results.any?).to eql(false)
            end

            context "contact org inspection" do
              before(:each) do
                @original = @original[:affiliations].first
              end

              it "attached the Org to the Contact" do
                expect(@contact.org.present?).to eql(true)
              end
              it "sets the name" do
                expect(@contact.org.name).to eql(@original[:name])
              end
              it "sets the abbreviation" do
                expect(@contact.org.abbreviation).to eql(@original[:abbreviation])
              end
              it "Org identifiers includes the affiation id" do
                expect(@contact.org.identifiers.length).to eql(1)
                expected = @original[:affiliation_ids].first[:type]
                expect(@contact.org.identifiers.first.identifier_scheme.name).to eql(expected)

                expected = @original[:affiliation_ids].first[:identifier]
                expect(@contact.org.identifiers.first.value).to eql(expected)
              end
              it "is the same as the Plan's org" do
                expect(@plan.org).to eql(@contact.org)
              end
            end
          end

          context "contributor inspection" do
            before(:each) do
              @original = @original[:contributors].first
              contributors = @plan.contributors.select do |pc|
                pc.email == @original[:mbox]
              end
              @subject = contributors.first
            end

            it "attached the Contributor to the Plan" do
              expect(@subject.present?).to eql(true)
            end
            it "set the Contributor firstname" do
              expect(@subject.firstname).to eql(@original[:firstname])
            end
            it "set the Contributor surname" do
              expect(@subject.surname).to eql(@original[:surname])
            end
            it "set the Contributor email" do
              expect(@subject.email).to eql(@original[:mbox])
            end
            it "set the Contributor roles" do
              expected = @original[:role].gsub("#{Contributor::CREDIT_TAXONOMY_URI_BASE}/", "")
              expect(@subject.send(:"#{expected.downcase}?")).to eql(true)
            end
            it "Contributor identifiers includes the orcid" do
              expect(@subject.identifiers.length).to eql(1)
              expected = @original[:contributor_ids].first[:type]
              expect(@subject.identifiers.first.identifier_scheme.name).to eql(expected)

              expected = @original[:contributor_ids].first[:identifier]
              expect(@subject.identifiers.first.value).to eql(expected)
            end

            context "contributor org inspection" do
              before(:each) do
                @original = @original[:affiliations].first
              end

              it "attached the Org to the Contributor" do
                expect(@subject.org.present?).to eql(true)
              end
              it "sets the name" do
                expect(@subject.org.name).to eql(@original[:name])
              end
              it "sets the abbreviation" do
                expect(@subject.org.abbreviation).to eql(@original[:abbreviation])
              end
              it "Org identifiers includes the affiation id" do
                expect(@subject.org.identifiers.length).to eql(1)
                expected = @original[:affiliation_ids].first[:type]
                expect(@subject.org.identifiers.first.identifier_scheme.name).to eql(expected)

                expected = @original[:affiliation_ids].first[:identifier]
                expect(@subject.org.identifiers.first.value).to eql(expected)
              end
            end
          end

          context "funder inspection" do
            before(:each) do
              @original = @original[:project][:funding].first
              @funder = @plan.funder
            end

            it "attached the Funder to the Plan" do
              expect(@funder.present?).to eql(true)
            end
            it "sets the name" do
              expect(@funder.name).to eql(@original[:name])
            end
            it "Funder identifiers includes the funder_id id" do
              expect(@funder.identifiers.length).to eql(1)
              expected = @original[:funder_ids].first[:type]
              expect(@funder.identifiers.first.identifier_scheme.name).to eql(expected)

              expected = @original[:funder_ids].first[:identifier]
              expect(@funder.identifiers.first.value.to_s).to eql(expected.to_s)
            end
          end

          it "set the Template id" do
            app = ApplicationService.application_name
            expected = @original[:extended_attributes][:"#{app}"][:template_id]
            expect(@plan.template_id).to eql(expected)
          end
        end

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
