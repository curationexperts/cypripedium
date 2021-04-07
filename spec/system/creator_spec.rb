# frozen_string_literal: true

require 'rails_helper'

include Warden::Test::Helpers

RSpec.describe 'Creators', type: :system, js: true do
  let(:admin_user) { FactoryBot.create(:admin) }
  context "as an unauthenticated user" do
    it "can show the index page" do
      visit "/creators"
      expect(page).to have_content(/Display name/i)
      expect(page).to have_content(/Alternate names/i)
    end

    it "cannot navigate to the new page" do
      visit "/creators/new"
      expect(page).to have_content("You are not authorized to access this page")
    end
  end
  context "as an admin" do
    let(:admin_user) { FactoryBot.create(:admin) }
    before do
      login_as admin_user
    end
    it "can show the index page" do
      visit "/creators"
      expect(page).to have_content(/ID/i)
      expect(page).to have_content(/Display name/i)
      expect(page).to have_content(/Alternate names/i)
    end
    it "can create a new creator record" do
      visit "/creators/new"
      expect(page).to have_field("Display name")
      expect(page).to have_field("Alternate names")
      fill_in "Display name", with: "Allen, Stephen G."
      fill_in "Alternate names", with: "Allen, S. Gomes ; Aliens, Steve"
      click_on "Save"
      expect(page).to have_content('["Allen, S. Gomes", "Aliens, Steve"]')
      expect(Creator.first.alternate_names).to eq ["Allen, S. Gomes", "Aliens, Steve"]
    end
    it "has a dashboard link to manage creators" do
      visit "/dashboard"
      expect(page).to have_link("Manage Embargoes")
      expect(page).to have_link("Manage Creators")
      click_on "Manage Creators"
      expect(page).to have_content(/ID/i)
      expect(page).to have_content(/Display name/i)
      expect(page).to have_content(/Alternate names/i)
    end
  end
end
