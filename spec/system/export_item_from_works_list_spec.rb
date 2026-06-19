# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'BagIt export from works list', type: :system, js: true do
  let(:admin) { FactoryBot.create(:admin) }
  let(:user) { FactoryBot.create(:user) }
  let!(:publication) { create(:publication, title: ['Test Publication'], depositor: user.user_key) }

  context 'as an admin user' do
    before { login_as admin }

    it 'shows the Create BagIt Export option in the Actions dropdown' do
      visit hyrax.dashboard_works_path
      within("tr#document_#{publication.id}") { click_on 'Select' }
      expect(page).to have_button('Create BagIt Export')
    end

    it 'creates an Export record and redirects to the exports index' do
      visit hyrax.dashboard_works_path
      within("tr#document_#{publication.id}") { click_on 'Select' }
      click_on 'Create BagIt Export'
      expect(page).to have_current_path(main_app.exports_path(locale: I18n.locale))
      expect(Export.last.items).to include(publication.id)
    end

    it 'enqueues an ExportJob' do
      visit hyrax.dashboard_works_path
      within("tr#document_#{publication.id}") { click_on 'Select' }
      expect {
        click_on 'Create BagIt Export'
      }.to have_enqueued_job(ExportJob)
    end
  end

  context 'as a non-admin user' do
    before { login_as user }

    it 'does not show the Create BagIt Export option' do
      visit hyrax.my_works_path
      within("tr#document_#{publication.id}") { click_on 'Select' }
      expect(page).not_to have_button('Create BagIt Export')
    end
  end
end
