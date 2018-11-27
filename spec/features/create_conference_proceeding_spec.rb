# Generated via
#  `rails generate hyrax:work ConferenceProceeding`
require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create a ConferenceProceeding', js: true do
  context 'a logged in user' do
    let(:user_attributes) do
      { email: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end

    before do
      AdminSet.find_or_create_default_admin_set_id
      login_as user
    end

    scenario do
      visit '/concern/conference_proceedings/new'
      expect(page).to have_content "Add New Conference Proceeding"

      # Only the 'title' field should be required
      expect(page).to have_css('li#required-metadata.incomplete')
      fill_in 'Title', with: 'Title 123'
      click_on 'Title'
      expect(page).to have_css('li#required-metadata.complete')
    end
  end
end
