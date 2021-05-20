# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Bagit export:', type: :system, js: true do
  let(:admin_user) { FactoryBot.create(:admin) }

  before do
    DatabaseCleaner.clean_with(:truncation)
    ActiveFedora::Cleaner.clean!
    AdminSet.find_or_create_default_admin_set_id
    Hyrax::CollectionType.find_or_create_default_collection_type

    login_as admin_user
  end

  let(:publication) { create(:publication, title: ['Pub XYZ']) }
  let(:data_set) { create(:dataset, title: ['DS XYZ']) }

  context 'exporting a bag' do
    let(:job_params) do
      { work_ids: [publication.id],
        user: admin_user,
        compression: 'zip' }
    end

    before do
      ActiveJob::Base.queue_adapter = :test
      [publication, data_set] # Create the records
    end

    it 'queues the bagit job' do
      visit Hyrax::Engine.routes.url_helpers.my_works_path

      # Click 'All Works' tab to trigger turbolinks
      click_on 'All Works'
      expect(page).to have_link(publication.title.first)
      expect(page).to have_link(data_set.title.first)

      # Select one of the records for bag export
      check "batch_document_#{publication.id}"
      click_on 'Add to Zip Bag'

      # Should redirect to notifications page
      expect(page).to have_current_path(Hyrax::Engine.routes.url_helpers.notifications_path(locale: I18n.locale))

      # Correct background job should queue
      expect(BagJob).to have_been_enqueued.with(job_params).exactly(:once)
    end
  end
end
