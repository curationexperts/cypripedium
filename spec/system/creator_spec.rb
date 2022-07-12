# frozen_string_literal: true

require 'rails_helper'

include Warden::Test::Helpers

RSpec.describe 'Creators', type: :system, js: true do
  let(:creator) { Creator.create(display_name: "Cheese, The Big") }
  let(:creator_with_alternates) { Creator.create(display_name: "Allen, Stephen G.", alternate_names: ["Allen, S. Gomes", "Aliens, Steve"]) }
  let(:work) { FactoryBot.create(:populated_dataset) }

  context "as an unauthenticated user" do
    it "can show the index page" do
      creator
      creator_with_alternates
      visit "/creators"
      expect(page).to have_content(/Display name/i)
      expect(page).to have_content(/Alternate names/i)
      expect(page).to have_content("Cheese, The Big", count: 1)
      expect(page).to have_content('Allen, S. Gomes ; Aliens, Steve')
      expect(page).to have_no_link("New Creator")
      expect(page).to have_no_link("Edit")
    end

    it "cannot navigate to the new page" do
      visit "/creators/new"
      expect(page).to have_content("You are not authorized to access this page")
    end
    it "does not link to edit an existing creator" do
      creator
      visit "/creators/#{creator.id}"
      expect(page).to have_content("Display name")
      expect(page).to have_content("Alternate names")
      expect(page).to have_content("RePEc")
      expect(page).to have_content("VIAF")
      expect(page).to have_link("Back")
      expect(page).to have_no_link("Edit")
    end
  end
  context "as an admin" do
    let(:admin_user) { FactoryBot.create(:admin) }
    let(:creator) { Creator.create(display_name: "Cheese, The Big") }
    let(:inactive_creator) { Creator.create(display_name: "Milk, The Small", active_creator: false) }
    before do
      login_as admin_user
    end
    it "can show the index page" do
      creator
      expect(creator.active_creator).to eq true
      inactive_creator
      visit "/creators"
      expect(page).to have_content(/ID/i)
      expect(page).to have_content(/Display name/i)
      expect(page).to have_content(/Alternate names/i)
      expect(page).to have_content("Cheese, The Big", count: 1)
      altnames = find(:xpath, "//*[@id=\"active\"]/table/tbody/tr[1]/td[3]").text
      expect(altnames).to eq ""
      expect(page).to have_link("Edit")
      expect(page).to have_link("New Creator")
      expect(page).to have_content("Milk, The Small", count: 1)
      expect(page).to have_content(/active/i, count: 1)
      expect(page).to have_content("true")
      expect(page).to have_content("false")
      expect(page).not_to have_link("Destroy")
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
    it "can show an existing creator" do
      creator
      visit "/creators/#{creator.id}"
      expect(page).to have_content("Display name")
      expect(page).to have_content("Alternate names")
      expect(page).to have_content("RePEc")
      expect(page).to have_content("VIAF")
      expect(page).to have_link("Back")
      expect(page).to have_link("Edit")
    end
    it "does not do weird things to the Alternate names array" do
      creator_with_alternates
      visit "/creators/#{creator_with_alternates.id}/edit"
      expect(page.find(:xpath, "//*[@id=\"edit_creator_1\"]/div[2]/ul/li[1]/input").value).to eq "Allen, S. Gomes"
      expect(page.find(:xpath, "//*[@id=\"edit_creator_1\"]/div[2]/ul/li[2]/input").value).to eq "Aliens, Steve"
      click_on "Save"
      expect(creator_with_alternates.reload.alternate_names).to eq ["Allen, S. Gomes", "Aliens, Steve"]
    end
  end
end
