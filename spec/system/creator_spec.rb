# frozen_string_literal: true

require 'rails_helper'

include Warden::Test::Helpers

RSpec.describe 'Creators', type: :system, js: true do
  context "as an unauthenticated user" do
    it "can show the index page" do
      visit "/creators"
      expect(page).to have_content("Display name")
      expect(page).to have_content("Alternate names")
    end

    it "can navigate to the edit page" do
      visit "/creators"
      click_link("New Creator")
      expect(page).to have_field("Display name")
      expect(page).to have_field("Alternate names")
    end
  end
end
