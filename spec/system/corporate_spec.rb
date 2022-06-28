# frozen_string_literal: true

require 'rails_helper'

include Warden::Test::Helpers

RSpec.describe 'Corporates', type: :system, js: true do
  let(:corporate) { Corporate.create(corporate_name: "test corporate Name", corporate_state: "Oklahoma", corporate_city: "Oklahoma City") }

  context "as an unauthenticated user" do
    it "can show the index page" do
      corporate
      visit "/corporates"
      expect(page).to have_content(/Corporate name/i)
      expect(page).to have_content(/Corporate state/i)
      expect(page).to have_content(/Corporate city/i)
      expect(page).to have_content("test corporate Name", count: 1)
      expect(page).to have_content("Oklahoma", count: 2)
      expect(page).to have_content("Oklahoma City", count: 1)
      expect(page).to have_no_link(/new corporate/i)
      expect(page).to have_no_link("Edit")
      expect(page).to have_no_link("Delete")
    end

    it "cannot navigate to the new page" do
      visit "/corporates/new"
      expect(page).to have_content("You are not authorized to access this page")
    end
    it "does not link to edit an existing creator" do
      corporate
      visit "/corporates/#{corporate.id}"
      expect(page).to have_content(/corporate name/i)
      expect(page).to have_content(/corporate state/i)
      expect(page).to have_content(/corporate city/i)
      expect(page).to have_content("test corporate Name")
      expect(page).to have_content("Oklahoma", count: 2)
      expect(page).to have_link("Back")
      expect(page).to have_no_link("Edit")
    end
  end
  context "as an admin" do
    let(:admin_user) { FactoryBot.create(:admin) }
    let(:corporate_admin) { Corporate.create(corporate_name: "test corporate Minnesoda", corporate_state: "Oklahoma", corporate_city: "Minneapolis") }
    before do
      login_as admin_user
    end
    it "can show the index page" do
      corporate_admin
      visit "/corporates"
      expect(page).to have_content(/Corporate name/i)
      expect(page).to have_content(/Corporate state/i)
      expect(page).to have_content(/Corporate city/i)
      expect(page).to have_content("test corporate Minnesoda", count: 1)
      expect(page).to have_content("Oklahoma", count: 1)
      expect(page).to have_content("Minneapolis", count: 1)
      expect(page).to have_link("New Corporate")
      expect(page).to have_link("Edit")
      expect(page).to have_link("Delete")
    end
    it "can create a new corporate record" do
      visit "/corporates/new"
      expect(page).to have_content(/Corporate name/i)
      expect(page).to have_content(/Corporate state/i)
      expect(page).to have_content(/Corporate city/i)
      fill_in "Corporate Name", with: "Corporate Alaska"
      select "Alaska", from: "Corporate State"
      fill_in "Corporate City", with: "Norman"
      click_on "Save"
      expect(page).to have_content("Corporate Alaska", count: 1)
      expect(page).to have_content('Norman', count: 1)
    end
    it "has a dashboard link to manage corporates" do
      visit "/dashboard"
      expect(page).to have_link("Manage Corporates")
      expect(page).to have_link("Manage Creators")
      click_on "Manage Corporates"
      expect(page).to have_content(/ID/i)
      expect(page).to have_content(/Corporate name/i)
      expect(page).to have_content(/Corporate state/i)
    end
    it "can show an existing corporate" do
      corporate_admin
      visit "/corporates/#{corporate_admin.id}"
      expect(page).to have_content(/Corporate name/i)
      expect(page).to have_content(/Corporate state/i)
      expect(page).to have_content(/Corporate city/i)
      expect(page).to have_content("test corporate Minnesoda", count: 1)
      expect(page).to have_content("Oklahoma", count: 1)
      expect(page).to have_content("Minneapolis", count: 1)
    end
    it "can edit an existing corporate" do
      corporate_admin
      visit "/corporates/#{corporate_admin.id}/edit"
      expect(page).to have_content(/Corporate name/i)
      expect(page).to have_content(/Corporate state/i)
      expect(page).to have_content(/Corporate city/i)
      input = page.find(:xpath, "//*[@id=\"edit_corporate_1\"]/div[1]/input")
      expect(input.value).to eq "test corporate Minnesoda"
      input.native.clear
      input.set('test corporate Minnesoda edited')
      select "Alaska", from: "Corporate State"
      click_on "Save"
      expect(page).to have_link("Back")
      expect(page).to have_link("Edit")
      expect(corporate_admin.reload.corporate_state).to eq "AK"
      expect(corporate_admin.reload.corporate_name).to eq "test corporate Minnesoda edited"
    end
    it "can delete an existing corporate" do
      corporate_admin
      visit "/corporates"
      expect(page).to have_link("Delete")
      accept_alert do
        click_on "Delete"
      end
      expect(page).to have_content("test corporate Minnesoda", count: 0)
    end
  end
end
