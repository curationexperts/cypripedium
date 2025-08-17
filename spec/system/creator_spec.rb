# frozen_string_literal: true

require 'rails_helper'

include Warden::Test::Helpers
include ActionView::RecordIdentifier

RSpec.describe 'Creators', :aggregate_failures, type: :system, js: true do
  let(:creator) { Creator.create!(display_name: "Cheese, The Big") }
  let(:creator_with_alternates) { Creator.create!(display_name: "Allen, Stephen G.", alternate_names: ["Allen, S. Gomes", "Aliens, Steve"]) }
  let(:inactive_creator) { Creator.create!(display_name: "Milk, The Small", active_creator: false) }

  before do
    @initial_locale = default_url_options[:locale]
    default_url_options[:locale] = I18n.default_locale
  end

  after do
    default_url_options[:locale] = @initial_locale
  end

  context "as an unauthenticated user" do
    it "can show the index page" do
      creator
      creator_with_alternates
      visit "/creators"
      expect(page).to have_selector('th.display_name', text: 'Display Name')
      expect(page).to have_selector('th.alternate_names', text: 'Alternate Names')
      expect(page).to have_content("Cheese, The Big", count: 1)
      expect(page).to have_content('Allen, S. Gomes ; Aliens, Steve')
      # unathenticated users can't edit or create new records
      expect(page).not_to have_link(href: edit_creator_path(inactive_creator))
      expect(page).not_to have_link(href: new_creator_path)
    end

    it "cannot navigate to the new page" do
      visit new_creator_path
      expect(page).to have_content("You are not authorized to access this page")
    end

    it "cannot navigate to the edit page" do
      visit edit_creator_path(creator)
      expect(page).to have_content("You are not authorized to access this page")
    end

    it "does not link to edit an existing creator" do
      visit creator_path(creator)
      expect(page).to have_content("Display name")
      expect(page).to have_content("Alternate names")
      expect(page).to have_content("RePEc")
      expect(page).to have_content("VIAF")
      expect(page).to have_link("Back")
      expect(page).to have_no_link(href: /edit/)
    end
  end

  context "as an admin" do
    let(:admin_user) { FactoryBot.create(:admin) }

    before do
      login_as admin_user
    end

    it "can show the index page" do
      creator
      inactive_creator
      visit creators_path
      expect(page).to have_content(/Display name/i)
      expect(page).to have_content(/Alternate names/i)
      expect(page).to have_content("Cheese, The Big", count: 1)
      expect(page).to have_selector("##{dom_id(creator)} td.alternate_names", text: '')
      expect(page).to have_link(href: edit_creator_path(inactive_creator))
      expect(page).to have_link(href: new_creator_path)
      expect(page).to have_content("Milk, The Small", count: 1)
      within(id: dom_id(creator)) do
        expect(page).to have_selector('.alternate_names', text: '')
        expect(page).to have_selector('.active_creator', text: 'true')
      end
      within(id: dom_id(inactive_creator)) do
        expect(page).to have_selector('.alternate_names', text: '')
        expect(page).to have_selector('.active_creator', text: 'false')
      end
      expect(page).not_to have_link("Destroy")
    end

    it "has a dashboard link to manage creators" do
      visit "/dashboard"
      expect(page).to have_link("Manage Creators", href: creators_path)
    end

    it "can show an existing creator" do
      visit creator_path(creator)
      expect(page).to have_content("Display name")
      expect(page).to have_content("Alternate names")
      expect(page).to have_content("RePEc")
      expect(page).to have_content("VIAF")
      expect(page).to have_link("Back")
      expect(page).to have_link("Edit")
    end

    it "does not do weird things to the Alternate names array" do
      visit edit_creator_path(creator_with_alternates)
      expect(page).to have_field(id: 'creator_display_name', with: 'Allen, Stephen G.')
      expect(page).to have_field(name: 'creator[alternate_names][]', with: "Aliens, Steve")
      click_on "Save"
      expect(creator_with_alternates.reload.alternate_names).to eq ["Allen, S. Gomes", "Aliens, Steve"]
    end
  end
end
