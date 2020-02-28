# frozen_string_literal: true

# Mock JSON submissions
module Mocks

  module ApiJsonSamples

    ROLES = %w[Investigation Project_administration Writing_original_draft].freeze


    def mock_identifier_schemes
      create(:identifier_scheme, name: "ror")
      create(:identifier_scheme, name: "orcid")
      create(:identifier_scheme, name: "grant")
    end

    def minimal_update_json
      {
        "total_items": 1,
        "items": [
          {
            "dmp": {
              "title": Faker::Lorem.sentence,
              "contact": {
                "name": Faker::TvShows::Simpsons.character,
                "mbox": Faker::Internet.email
              },
              "dmp_ids": [
                {
                  "type": "#{ApplicationService.application_name}",
                  "identifier": SecureRandom.uuid
                }
              ]
            }
          }
        ]
      }.to_json
    end

    def minimal_create_json
      {
        "total_items": 1,
        "items": [
          {
            "dmp": {
              "title": Faker::Lorem.sentence,
              "contact": {
                "name": Faker::TvShows::Simpsons.character,
                "mbox": Faker::Internet.email
              },
              "extended_attributes": {
                "#{ApplicationService.application_name}": {
                  "template_id": Template.last.id
                }
              }
            }
          }
        ]
      }.to_json
    end

    def complete_create_json
      {
        "total_items": 1,
        "items": [
          {
            "dmp": {
              "created": (Time.now - 3.months).utc.to_s,
              "title": Faker::Lorem.sentence,
              "description": Faker::Lorem.paragraph,
              "language": Language.all.pluck(:abbreviation).sample,
              "ethical_issues_exist": %w[yes no unknown].sample,
              "ethical_issues_description": Faker::Lorem.paragraph,
              "ethical_issues_report": Faker::Internet.url,
              "contact": {
                "firstname": Faker::TvShows::Simpsons.character.split.first,
                "surname": Faker::TvShows::Simpsons.character.split.last,
                "mbox": Faker::Internet.email,
                "role": "https://dictionary.casrai.org/Contributor_Roles/Data_curation",
                "affiliations": [{
                  "name": Faker::TvShows::Simpsons.location,
                  "abbreviation": Faker::Lorem.word.upcase,
                  "region": Faker::Space.planet,
                  "affiliation_ids": [{
                    "type": "ror",
                    "identifier": SecureRandom.uuid
                  }]
                }],
                "contributor_ids": [{
                  "type": "orcid",
                  "identifier": SecureRandom.uuid
                },
                {
                  "type": Faker::Lorem.word,
                  "identifier": Faker::Number.number
                }]
              },
              "contributors": [{
                "role": "https://dictionary.casrai.org/Contributor_Roles/#{ROLES.sample}",
                "firstname": Faker::Movies::StarWars.character.split.first,
                "surname": Faker::Movies::StarWars.character.split.last,
                "mbox": Faker::Internet.email,
                "affiliations": [{
                  "name": Faker::Movies::StarWars.planet,
                  "abbreviation": Faker::Lorem.word.upcase
                }],
                "contributor_ids": [{
                  "type": "orcid",
                  "identifier": SecureRandom.uuid
                }]
              }],
              "project": {
                "title": Faker::Lorem.sentence,
                "description": Faker::Lorem.paragraph,
                "start_on": (Time.now + 3.months).utc.to_s,
                "end_on": (Time.now + 2.years).utc.to_s,
                "funding": [{
                  "name": Faker::Movies::StarWars.droid,
                  "funder_ids": [{
                    "type": Faker::Lorem.word,
                    "identifier": Faker::Number.number
                  }],
                  "grant_ids": [{
                    "type": "grant",
                    "identifier": SecureRandom.uuid
                  }],
                  "funding_status": %w[planned applied granted].sample
                }]
              },
              "extended_attributes": {
                "#{ApplicationService.application_name}": {
                  "template_id": Template.last.id
                }
              }
            }
          }
        ]
      }.to_json
    end
  end

end
