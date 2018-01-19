# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Publication do
  let(:work) { FactoryBot.build(:publication) }
  it_behaves_like 'a work with additional metadata'
end
