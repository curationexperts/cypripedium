# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Collection landing page', type: :system, clean: true, js: true do
  let(:admin_user) { FactoryBot.create(:admin) }
  let(:collection) do
    Collection.create!(
      title: ['Collection 1'],
      collection_type: Hyrax::CollectionType.find_or_create_default_collection_type,
      description: ['My amazing collection']
    )
  end
  let(:titles) do
    [
      'Antsy Aardvark',
      'Busy Beaver',
      'Cunning Cougar',
      'Devious Dog',
      'Elegant Elephant'
    ]
  end
  let(:collection_members) do
    titles.each.with_index(1) do |title, i|
      FactoryBot.create(:publication,
                        issue_number: [i.to_s],
                        title: [title],
                        depositor: admin_user.user_key,
                        member_of_collections: [collection])
    end
  end

  before do
    collection_members
    login_as admin_user
  end

  context 'result sorting' do
    it 'defaults to issue number descending', :aggregate_failures do
      visit Hyrax::Engine.routes.url_helpers.collection_path(collection.id)
      issue_numbers = page.all('tr.document td.issue_number').map(&:text)
      expect(issue_numbers).to eq ['5', '4', '3', '2', '1']
    end

    it 'can reorder by title' do
      visit Hyrax::Engine.routes.url_helpers.collection_path(collection.id)

      # titles should show up in reverse order because of issue number sorting
      publication_titles = page.all('tr.document p.media-heading').map(&:text)
      expect(publication_titles).to eq titles.reverse

      # change sort order
      select 'title ▲', from: 'sort'
      publication_titles = page.all('tr.document p.media-heading').map(&:text)
      expect(publication_titles).to eq titles
    end

    it 'returns a relevance sort when the user supplies a search parameter' do
      visit Hyrax::Engine.routes.url_helpers.collection_path(collection.id, cq: 'Cougar')
      publication_titles = page.all('tr.document p.media-heading').map(&:text)
      expect(publication_titles.first).to eq 'Cunning Cougar'
    end
  end
end
