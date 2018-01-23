# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ConferenceProceeding do
  let(:work) { FactoryBot.build(:conference_proceeding) }
  it_behaves_like 'a work with additional metadata'
end
