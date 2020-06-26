# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Use structured data that Google can parse', type: :system, clean: true, js: true do
  context "datasets" do
    let(:work) { FactoryBot.create(:populated_dataset) }
    it "marks creators with schema.org tags" do
      visit "/concern/datasets/#{work.id}"
      creators = page.all(:css, "[itemprop='creator']")
      expect(creators.first.text).to eq "McGrattan, Ellen R."
      expect(creators.last.text).to eq "Prescott, Edward C."
    end

    it "marks abstract with schema.org tags" do
      visit "/concern/datasets/#{work.id}"
      expect(page.find(:css, '[itemprop="abstract"]').text).to eq "This is my abstract"
      expect(page).not_to have_selector('[itemprop="abstract"][itemtype]')
    end
    it "marks identifier with schema.org tags" do
      visit "/concern/datasets/#{work.id}"
      expect(page.find(:css, '[itemprop="identifier"]').text.strip).to eq "https://doi.org/10.21034/sr.600"
      expect(page).not_to have_selector('[itemprop="identifier"][itemtype]')
    end
    it "marks description with schema.org tags" do
      visit "/concern/datasets/#{work.id}"
      expect(page.find(:css, '[itemprop="description"]').text.strip).to eq "This is my description"
      expect(page).not_to have_selector('[itemprop="description"][itemtype]')
    end
    xit "marks license with schema.org tags" do
      visit "/concern/datasets/#{work.id}"
      expect(page.find(:css, '[itemprop="license"]').text.strip).to eq "This is my license"
      expect(page).not_to have_selector('[itemprop="license"][itemtype]')
    end
  end
  context "dataset without description field" do
    let(:work) { FactoryBot.create(:dataset_without_description) }
    let(:related_url) do
      "Data supports Staff Report 315, \"Does Neoclassical Theory Account for the Effects of Big Fiscal Shocks? Evidence From World War II.\" https://doi.org/10.21034/sr.315"
    end
    it "marks related_url with description schema.org tags" do
      visit "/concern/datasets/#{work.id}"
      expect(page.find(:css, '[itemprop="description"]').text.strip).to eq related_url
    end
  end
  context "publications" do
    let(:work) { FactoryBot.create(:populated_publication) }
    it "marks abstract with schema.org tags" do
      visit "/concern/publications/#{work.id}"
      expect(page.find(:css, '[itemprop="abstract"]').text).to eq "This is my abstract"
      expect(page).not_to have_selector('[itemprop="abstract"][itemtype]')
    end
  end
end
