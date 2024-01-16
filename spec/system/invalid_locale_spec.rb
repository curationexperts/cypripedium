# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Getting a friendly error for Invalid Locales', type: :system do
  # The empty before block allows these tests to pass in CI
  before do
  end
  context 'visiting a locale that does not exist' do
    it 'has a 406 page' do
      visit('/?locale=pluto')
      expect(page).to have_content('Research Database')
      expect(page).to have_content('Error: Invalid language selection')
      expect(page).to have_content('Please select a valid language from the selector')
    end
  end

  context 'visiting a valid locale' do
    it 'gives the content in the correct language' do
      visit('/?locale=en')
      expect(page).to have_content('Welcome to the Research Database')
    end
  end
end
