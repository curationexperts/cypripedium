# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Use structured data that Google can parse', type: :system, clean: true, js: true do
  let(:work) { FactoryBot.create(:populated_dataset) }

  context "expected Google data is exposed"
  it "marks creators with schema.org tags" do
    visit "/concern/publications/#{work.id}"
    creators = page.all(:css, "[itemprop='creator']")
    expect(creators.first.text).to eq "McGrattan, Ellen R."
    expect(creators.last.text).to eq "Prescott, Edward C."
  end

  it "marks abstract with schema.org tags" do
    visit "/concern/publications/#{work.id}"
    expect(page.find(:css, '[itemprop="abstract"]').text).to eq "This is my abstract"
  end
end
