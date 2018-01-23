# Generated via
#  `rails generate hyrax:work Publication`
require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a Publication', js: true do
  context 'a logged in admin user' do
    let(:user) { FactoryBot.create(:admin) }
    before do
      login_as user
      AdminSet.find_or_create_default_admin_set_id
    end

    scenario do
      visit '/concern/publications/new'
      expect(page).to have_content "Add New Publication"
      fill_in 'Title', with: 'Title'
      fill_in 'Creator', with: 'Creator'
      fill_in 'Keyword', with: 'Keyword'
      select 'In Copyright', from: 'Rights statement'
      click_on 'Additional fields'
      fill_in 'Abstract', with: 'Abstract'
      fill_in 'Alternative Title', with: 'Alternative Title'
      fill_in 'Bibliographic Citation', with: 'Bibliographic Citation'
      fill_in 'Contributor', with: 'Contributor'
      fill_in 'Corporate Author', with: 'Corporate Author'
      fill_in 'Creator', with: 'Creator'
      fill_in 'Date Available', with: 'Date Available'
      fill_in 'Description', with: 'Description'
      fill_in 'Extent', with: 'Extent'
      fill_in 'Relation: Has Part', with: 'Relation: Has Part'
      fill_in 'Relation: Is Version Of', with: 'Relation: Is Version Of'
      fill_in 'Relation: Has Version', with: 'Relation: Has Version'
      fill_in 'Relation: Is Replaced By', with: 'Relation: Is Replaced By'
      fill_in 'Language', with: 'Language'
      fill_in 'Publisher', with: 'Publisher'
      fill_in 'Relation: Replaces', with: 'Relation: Replaces'
      fill_in 'Relation: Requires', with: 'Relation: Requires'
      select 'Article', from: 'Resource type'
      fill_in 'Source', with: 'Source'
      fill_in 'Spatial', with: 'Spatial'
      fill_in 'Subject', with: 'Subject'
      fill_in 'Table of Contents', with: 'Table of Contents'
      fill_in 'Temporal', with: 'Temporal'

      click_link "Files"

      execute_script("$('.fileinput-button input:first').css({'opacity':'1', 'display':'block', 'position':'relative'})")
      attach_file('files[]', File.absolute_path(file_fixture('pdf-sample.pdf')))
      sleep(1)
      find('#agreement').click

      find('#with_files_submit').click

      expect(page).to have_content('Abstract')
      expect(page).to have_content('Alternative Title')
      expect(page).to have_content('Bibliographic Citation')
      expect(page).to have_content('Contributor')
      expect(page).to have_content('Corporate Author')
      expect(page).to have_content('Creator')
      expect(page).to have_content('Date Available')
      expect(page).to have_content('Description')
      expect(page).to have_content('Extent')
      expect(page).not_to have_content('Relation: Has Part')
      expect(page).not_to have_content('Relation: Is Version Of')
      expect(page).not_to have_content('Relation: Has Version')
      expect(page).not_to have_content('Relation: Is Replaced By')
      expect(page).to have_content('Language')
      expect(page).to have_content('Publisher')
      expect(page).to have_content('Relation: Replaces')
      expect(page).not_to have_content('Relation: Requires')
      expect(page).to have_content('Article')
      expect(page).to have_content('Source')
      expect(page).to have_content('Spatial')
      expect(page).to have_content('Subject')
      expect(page).to have_content('Table of Contents')
      expect(page).to have_content('Temporal')
      expect(page).to have_content('Title')
    end
  end
end
