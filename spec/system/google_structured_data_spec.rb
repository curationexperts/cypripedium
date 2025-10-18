# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Use structured data that Google can parse', type: :system, clean: true, js: true do
  let(:creator_one) { FactoryBot.create(:creator, display_name: 'McGrattan, Ellen R.') }
  let(:creator_two) { FactoryBot.create(:creator, display_name: 'Prescott, Edward C.') }
  let(:work) { FactoryBot.create(:populated_dataset, creators: [creator_one, creator_two]) }

  context "datasets" do
    it "marks up with schema.org tags", :aggregate_failures do
      visit "/concern/datasets/#{work.id}"
      creators = page.all(:css, "[itemprop='creator']")
      expect(creators.first.text).to eq "McGrattan, Ellen R."
      expect(creators.last.text).to eq "Prescott, Edward C."
      expect(page).to have_css('[itemprop="abstract"]', text: 'This is my abstract')
      expect(page).not_to have_css('[itemprop="abstract"][itemtype]')
      expect(page).to have_css('[itemprop="identifier"]', text: 'https://doi.org/10.21034/sr.600')
      expect(page).not_to have_css('[itemprop="identifier"][itemtype]')
      expect(page).to have_css('[itemprop="description"]', text: 'This is my description')
      expect(page).not_to have_css('[itemprop="description"][itemtype]')
      expect(page).to have_css('[itemprop="license"][itemtype="http://schema.org/CreativeWork"]', text: "Creative Commons BY-NC Attribution-NonCommercial 4.0 International")
    end
  end

  context "dataset without description field" do
    let(:work) { FactoryBot.create(:dataset_without_description) }
    let(:related_url) do
      "Data supports Staff Report 315, \"Does Neoclassical Theory Account for the Effects of Big Fiscal Shocks? Evidence From World War II.\" https://doi.org/10.21034/sr.315"
    end
    it "marks related_url with description schema.org tags" do
      visit "/concern/datasets/#{work.id}"
      expect(page).to have_css('[itemprop="description"]', text: related_url)
    end
  end
  context "publications" do
    let(:work) { FactoryBot.create(:populated_publication, abstract: ['This is my abstract']) }
    it "marks abstract with schema.org tags" do
      visit "/concern/publications/#{work.id}"
      expect(page).to have_css('[itemprop="abstract"]', text: 'This is my abstract')
      expect(page).not_to have_css('[itemprop="abstract"][itemtype]')
    end
  end
end
