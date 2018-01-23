# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DataSet do
  let(:work) { FactoryBot.build(:data_set) }
  it_behaves_like 'a work with additional metadata'
end
