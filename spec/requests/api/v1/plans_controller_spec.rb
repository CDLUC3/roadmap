# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::PlansController, type: :request do

  before(:each) do
    @client = create(:api_client)
  end

  context "actions" do

  end

  context "private methods" do
    before(:each) do
      @controller = described_class.new
    end


# TODO: move these up in the index action test to verify pagination is retained
    describe "#pagination_params" do
      before(:each) do
        @empty = OpenStruct.new(page: nil, per_page: nil)
        @paginated = OpenStruct.new(page: 2, per_page: 50)
      end

      it "defaults the page to 1" do
        @controller.expects(:request).returns(@empty)
        @controller.send(:pagination_params)
        expect(@controller.send(:page)).to eql(1)
      end
      it "defaults the per_page to 25" do
        @controller.expects(:request).returns(@empty)
        @controller.send(:pagination_params)
        expect(@controller.send(:per_page)).to eql(20)
      end
      it "picks up the page from the params" do
        @controller.expects(:request).returns(@paginated)
        @controller.send(:pagination_params)
        expect(@controller.send(:@page)).to eql(2)
      end
      it "picks up the per_page from the params" do
        @controller.expects(:request).returns(@paginated)
        @controller.send(:pagination_params)
        expect(@controller.send(:per_page)).to eql(50)
      end
      it "does not allow more than 100 per_page" do
        struct = OpenStruct.new(page: 2, per_page: 101)
        @controller.expects(:request).returns(struct)
        @controller.send(:pagination_params)
        expect(@controller.send(:per_page)).to eql(100)
      end
    end

  end

end