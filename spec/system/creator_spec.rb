# frozen_string_literal: true

require 'rails_helper'

include Warden::Test::Helpers

RSpec.describe 'Creators', type: :system, js: true do
  let(:admin_user) { FactoryBot.create(:admin) }
  context "as an unauthenticated user" do
    skip "can show the index page" do
      visit "/creators"
      expect(page).to have_content("Display name")
      expect(page).to have_content("Alternate names")
    end

    it "cannot navigate to the edit page" do
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
      expect(page).to have_content("ID")
      expect(page).to have_content("Display name")
      expect(page).to have_content("Alternate names")
    end
  end
end
