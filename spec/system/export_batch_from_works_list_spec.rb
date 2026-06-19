# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'BagIt batch export from works list', type: :system, js: true do
  let(:admin) { FactoryBot.create(:admin) }
  let(:user)  { FactoryBot.create(:user) }
  let!(:publication)  { create(:publication, title: ['First Publication'],  depositor: user.user_key) }
  let!(:publication2) { create(:publication, title: ['Second Publication'], depositor: user.user_key) }

  context 'as an admin user' do
    before { login_as admin }

    it 'shows the Create BagIt Export button in the batch actions bar when works are selected' do
      visit hyrax.dashboard_works_path
      check "batch_document_#{publication.id}"
      expect(page).to have_button('Create BagIt Export')
    end

    it 'does not show the Create BagIt Export button when no works are selected' do
      visit hyrax.dashboard_works_path
      expect(page).not_to have_button('Create BagIt Export', visible: true)
    end

    it 'creates an Export with the selected work ids and redirects to the exports index', :aggregate_failures do
      visit hyrax.dashboard_works_path
      check "batch_document_#{publication.id}"
      check "batch_document_#{publication2.id}"
      click_on 'Create BagIt Export'
      expect(page).to have_current_path(main_app.exports_path(locale: :en))
      expect(Export.last.items).to contain_exactly(publication.id, publication2.id)
    end

    it 'enqueues an ExportJob for the selected works' do
      visit hyrax.dashboard_works_path
      check "batch_document_#{publication.id}"
      expect {
        click_on 'Create BagIt Export'
      }.to have_enqueued_job(ExportJob)
    end
  end

  context 'as a non-admin user' do
    before { login_as user }

    it 'does not show the Create BagIt Export button' do
      visit hyrax.my_works_path
      check "batch_document_#{publication.id}"
      expect(page).not_to have_button('Create BagIt Export')
    end
  end
end
