# frozen_string_literal: true

require "swagger_helper"

describe "Plans API" do

  path "/api/v1/plans" do

    post 'Creates a plan' do
      tags "Plans"
      consumes "application/x-www-form-urlencoded"
      security [http: []]

      parameter name: :authorization, in: :header, type: :string

      parameter name: :json, in: :body, schema: {
        type: :object,
        properties: {
          total_items: { type: :integer, example: 1 },
          items: {
            type: :array,
            items: {
              type: :object,
              properties: {
                dmp: {
                  type: :object,
                  properties: {
                    title: { type: :string, example: "My new data management plan", required: true },
                    description: { type: :string, example: "The abstract for my data management plan" },
                    created: { type: :string, example: Time.now.utc.to_s },
                    language: { type: :string, example: "en" },
                    ethical_issues: { type: :boolean, example: true },
                    ethical_issues_description: { type: :string, example: "A summary of any ethical concerns related to my research data." },
                    ethical_issues_report: { type: :string, example: "https://my-org.edu/path/to/my/ethical_issues_report.pdf" },
                    dmp_ids: {
                      type: :array,
                      items: { "$ref": "#/definitions/identifier_object" }
                    },
                    contact: {
                      type: :object,
                      properties: {
                        firstname: { type: :string, example: "John" },
                        surname: { type: :string, example: "Smith" },
                        mbox: { type: :string, example: "john.smith@nowhere.edu" },
                        role: {
                          type: :string,
                          example: "#{Contributor::ONTOLOGY_BASE_URL}/DataCuration" },
                        affiliations: {
                          type: :array,
                          items: { "$ref": "#/definitions/affiliation_object" }
                        },
                        contributor_ids: {
                          type: :array,
                          items: { "$ref": "#/definitions/identifier_object" }
                        }
                      },
                      required: %w[mbox role]
                    },
                    contributors: {
                      type: :array,
                      items: { "$ref": "#/definitions/contributor_object" }
                    },
                    project: { "$ref": "#/definitions/project_object" },
                    extended_attributes: {
                      type: :array,
                      items: {
                        type: :object,
                        properties: {
                          dmptool: {
                            type: :object,
                            properties: {
                              template_id: { type: :integer, example: 123 }
                            }
                          }
                        }
                      }
                    }
                  },
                  required: %w[title contact]
                }
              }
            }
          }
        },
        required: %w[total_items items]
      }

      response "201", "created" do
        run_test!
      end

      response "400", "bad request - if JSON is invalid or Plan already exists" do
        #schema '$ref': '#/definitions/bad_request_error'
        run_test!
      end

      response "401", "authorization failed - please provide your credentials" do
        run_test!
      end

    end

  end

end
