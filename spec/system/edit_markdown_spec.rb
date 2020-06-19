# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Edit markdown fields:', type: :system, js: true do
  let(:admin_user) { FactoryBot.create(:admin) }

  before do
    DatabaseCleaner.clean_with(:truncation)
    ActiveFedora::Cleaner.clean!
    AdminSet.find_or_create_default_admin_set_id
    login_as admin_user
  end

  context 'edit a collection' do
    let(:collection) do
      coll = Collection.new(
        title: ['Collection 1'],
        collection_type: Hyrax::CollectionType.find_or_create_default_collection_type,
        description: ['Old Description']
      )
      coll.apply_depositor_metadata(admin_user.user_key)
      coll.save!
      coll
    end

    # The new description contains markdown text
    let(:new_description) { [good_markdown, malicious_markdown, good_markdown_2].join("\n\n") }
    let(:good_markdown) { 'An [example of a link](http://example.com/) inside a sentence with *italic text*.' }
    let(:good_markdown_2) { '>This is a blockquote' }
    let(:malicious_markdown) { '<script>console.log("javascript attack");</script>' }

    it 'properly saves and displays the markdown' do
      # The form to edit this collection
      visit Hyrax::Engine.routes.url_helpers.edit_dashboard_collection_path(collection.id)

      # When the form loads, we see the old description
      expect(page).to have_content 'Old Description'

      # Fill in the new description and save
      fill_in 'Description', with: new_description
      click_on 'Save changes'

      # Go to the show page for this collection
      visit Hyrax::Engine.routes.url_helpers.dashboard_collection_path(collection.id)

      # The markdown should be rendered
      expect(page).to have_link('example of a link', href: 'http://example.com/')
      expect(page).to have_selector('em', text: 'italic text')

      within('blockquote') do
        expect(page).to have_content 'This is a blockquote'
      end

      # The potentially malicious javascript should not be run, but should be displayed as text instead
      expect(page).to have_content('console.log(')

      # Go to the search results page
      visit search_catalog_path

      # The markdown should be rendered
      expect(page).to have_link('example of a link', href: 'http://example.com/')
      expect(page).to have_selector('em', text: 'italic text')

      # The javascript should be displayed as text
      expect(page).to have_content('console.log(')
    end
  end
end
