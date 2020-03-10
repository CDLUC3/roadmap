require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'

  # Commenting out `openapi: 3.0.1` because rswag does not yet support that
  # version which uses `requestBody` instead of `body` for POST/PUT endpoints!
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      swagger: '2.0', # openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      securityDefinitions: {
        bearerAuth: {
          type: :apiKey,
          description: "Bearer token",
          name: "Authorization",
          in: :header

        }
      },
      definitions: {
        identifier_object: {
          type: :object,
          properties: {
            type: {
              enum: IdentifierScheme.where.not(name: "shibboleth").pluck(:name)
            },
            identifier: { type: :string, example: SecureRandom.uuid.to_s }
          },
          required: %w[type identifier]
        },
        affiliation_object: {
          type: :object,
          properties: {
            name: { type: :string, example: "University of Nowhere" },
            abbreviation: { type: :string, example: "UN" },
            region: { type: :string, example: "United States" },
            affiliation_ids: {
              type: :array,
              items: { "$ref": "#/definitions/identifier_object" }
            },
          },
          required: %w[name]
        },
        contributor_object: {
          type: :object,
          properties: {
            firstname: { type: :string, example: "Jane" },
            surname: { type: :string, example: "Doe" },
            mbox: { type: :string, example: "jane.doe@nowhere.edu" },
            role: {
              type: :string,
              enum: [
                Contributor.new.all_roles.map do |r|
                  "#{Contributor::ONTOLOGY_BASE_URL}/#{r.to_s.capitalize}"
                end
              ],
              example: "#{Contributor::ONTOLOGY_BASE_URL}/#{Contributor.new.all_roles.first.to_s.capitalize}" },
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
        funding_object: {
          type: :object,
          properties: {
            name: { type: :string, example: "National Science Foundation" },
            funding_status: { enum: %w[planned applied granted] },
            funder_ids: {
              type: :array,
              items: { "$ref": "#/definitions/identifier_object" }
            },
            grant_ids: {
              type: :array,
              items: { "$ref": "#/definitions/identifier_object" }
            }
          },
          required: %w[name funding_status]
        },
        project_object: {
          type: :object,
          properties: {
            title: { type: :string, example: "Study of API development in open source codebases" },
            description: { type: :string, example: "An abstract describing the overall research project" },
            start_on: { type: :string, example: (Time.now + 3.months).utc.to_s },
            end_on: { type: :string, example: (Time.now + 38.months).utc.to_s },
            funding: {
              type: :array,
              items: { "$ref": "#/definitions/funding_object" }
            }
          },
          required: %w[title"]
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml
end
