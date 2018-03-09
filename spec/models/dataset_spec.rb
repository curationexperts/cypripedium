# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Dataset do
  let(:work) { FactoryBot.build(:dataset) }
  it_behaves_like 'a work with additional metadata'
end
