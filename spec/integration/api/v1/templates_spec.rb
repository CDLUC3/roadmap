# frozen_string_literal: true

require "swagger_helper"

describe "Templates API" do

  path "/api/v1/templates" do

    get 'Returns the templates' do
      tags "Templates"
      consumes "application/x-www-form-urlencoded"
      security [http: []]

      response "200", "success" do
        let(:user) { create(:api_client) }
        let(:Authorization) { "Bearer #{Api::Auth::Jwt::JsonWebToken.encode(user.client_id)}" }
        run_test!
      end

      response "401", "authorization failed - please provide your credentials" do
        let(:Authorization) { "Bearer #{Api::Auth::Jwt::JsonWebToken.encode("foo")}" }
        run_test!
      end

    end

  end

end
