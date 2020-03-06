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
                      items: {
                        type: :object,
                        properties: {
                          type: { type: :string, example: "external-system" },
                          identifier: { type: :string, example: 1234 }
                        },
                        required: %i[type identifier]
                      }
                    },
                    contact: {
                      type: :object,
                      properties: {
                        firstname: { type: :string, example: "Jane" },
                        surname: { type: :string, example: "Doe" },
                        mbox: { type: :string, example: "jane.doe@my-org.edu" },
                        role: { type: :string, example: "https://dictionary.casrai.org/Contributor_Roles/Data_curation" },
                        affiliations: {
                          type: :array,
                          items: {
                            type: :object,
                            properties: {
                              name: { type: :string, example: "University of Nowhere" },
                              abbreviation: { type: :string, example: "UN" },
                              region: { type: :string, example: "United States" },
                              affiliation_ids: {
                                type: :array,
                                items: {
                                  type: :object,
                                  properties: {
                                    type: { type: :string, example: "ror" },
                                    identifier: { type: :string, example: "https://ror.org/0153tk833" }
                                  },
                                  required: %i[type identifier]
                                }
                              }
                            }
                          }
                        },
                        contributor_ids: {
                          type: :array,
                          items: {
                            type: :object,
                            properties: {
                              type: { type: :string, example: "orcid" },
                              identifier: { type: :string, example:"0000-0000-0000-0001" }
                            },
                            required: %i[type identifier]
                          }
                        }
                      },
                      required: %i[role mbox]
                    },
                    contributors: {
                      type: :array,
                      items: {
                        type: :object,
                        properties: {
                          firstname: { type: :string, example: "John" },
                          surname: { type: :string, example: "Smith" },
                          mbox: { type: :string, example: "john.smith@my-org.edu" },
                          role: { type: :string, example: "https://dictionary.casrai.org/Contributor_Roles/Investigation" },
                          affiliations: {
                            type: :array,
                            items: {
                              type: :object,
                              properties: {
                                name: { type: :string, example: "University of Nowhere" },
                                abbreviation: { type: :string, example: "UN" },
                                region: { type: :string, example: "United States" },
                                affiliation_ids: {
                                  type: :array,
                                  items: {
                                    type: :object,
                                    properties: {
                                      type: { type: :string, example: "ror" },
                                      identifier: { type: :string, example: "https://ror.org/098zy987" }
                                    },
                                    required: %i[type identifier]
                                  }
                                }
                              }
                            }
                          },
                          contributor_ids: {
                            type: :array,
                            items: {
                              type: :object,
                              properties: {
                                type: { type: :string, example: "orcid" },
                                identifier: { type: :string, example:"0000-0000-0000-0002" }
                              },
                              required: %i[type identifier]
                            }
                          }
                        }
                      }
                    },
                    project: {
                      type: :object,
                      properties: {
                        title: { type: :string, example: "Study of API development in open source codebases" },
                        description: { type: :string, example: "An abstract describing the overall research project" },
                        start_on: { type: :string, example: (Time.now + 3.months).utc.to_s },
                        end_on: { type: :string, example: (Time.now + 38.months).utc.to_s },
                        funding: {
                          type: :array,
                          items: {
                            type: :object,
                            properties: {
                              name: "National Science Foundation",
                              funding_status: "granted",
                              funder_ids: {
                                type: :array,
                                items: {
                                  type: :object,
                                  properties: {
                                    type: { type: :string, example: "fundref" },
                                    identifier: { type: :string, example:"https://api.crossref.org/funders/100000014" }
                                  },
                                  required: %i[type identifier]
                                }
                              },
                              grant_ids: {
                                type: :array,
                                items: {
                                  type: :object,
                                  properties: {
                                    type: { type: :string, example: "grant" },
                                    identifier: { type: :string, example: "123456789" }
                                  },
                                  required: %i[type identifier]
                                }
                              }
                            }
                          }
                        }
                      },
                      required: ["title"]
                    },
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
                  required: %i[title contact]
                }
              }
            }
          }
        },
        required: %i[total_items items]
      }

      response "201", "created" do
        run_test!
      end

      response "400", "bad request - if JSON is invalid or Plan already exists" do
        run_test!
      end

      response "401", "authorization failed - please provide your credentials" do
        run_test!
      end

    end

  end

end
