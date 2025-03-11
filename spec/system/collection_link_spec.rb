# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Collections listing', type: :system do
  let(:admin_user) { FactoryBot.create(:admin) }
  let(:collection) do
    Collection.create!(
      title: ['Collection 1'],
      collection_type: Hyrax::CollectionType.find_or_create_default_collection_type,
      description: ['A Collection']
    )
  end
  let(:titles) do
    [
      'Work One',
      'Work Two'
    ]
  end
  let(:collection_members) do
    titles.each.with_index(1) do |title, i|
      FactoryBot.create(:publication,
                        title: [title],
                        depositor: admin_user.user_key,
                        member_of_collections: [collection])
    end
  end

  before do
    collection_members
    login_as admin_user
  end

  context 'from homepage link' do
    it 'displays only collections', :aggregate_failures do
      visit root_path
      click_on 'all_collections'
      expect(page).to have_content 'A Collection'
      expect(page).not_to have_content 'Work One'
      expect(page).not_to have_content 'Work Two'
    end
  end
end
