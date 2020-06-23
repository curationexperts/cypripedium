# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Use structured data that Google can parse', type: :system, clean: true, js: true do
  let(:work) { FactoryBot.create(:populated_dataset) }

  context "creator names"
  it "has expected Google data exposed" do
    visit "/concern/publications/#{work.id}"

    creators = page.all(:css, 'li.attribute.attribute-alpha_creator')
    expect(creators.first.find(:css, "[itemprop]").text).to eq "McGrattan, Ellen R."
    expect(creators.last.find(:css, "[itemprop]").text).to eq "Prescott, Edward C."
  end
end
