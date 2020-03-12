# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contributor, type: :model do

  context "validations" do
    subject { build(:contributor) }
  end

  context "associations" do
    it { is_expected.to belong_to(:org) }
    it { is_expected.to belong_to(:plan) }
    it { is_expected.to have_many(:identifiers) }
  end

end
