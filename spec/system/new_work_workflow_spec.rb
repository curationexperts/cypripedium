# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'New work creation', type: :system, js: true do
  let(:admin_user) { FactoryBot.create(:admin) }

  before do
    # Create legacy default AdminSet (ActiveFedora)
    # Mimics Hyrax::AdminSetCreateService, but persists the default admin set to Fedora instead of the Database
    default_admin_set = AdminSet.where(id: 'admin_set/default').first ||
                        AdminSet.create!(id: 'admin_set/default', title: ['Default Admin Set'])
    permission_template = Hyrax::Collections::PermissionsCreateService.create_default(collection: default_admin_set, creating_user: nil)
    Hyrax::AdminSetCreateService.new(admin_set: default_admin_set, creating_user: nil).send(:create_workflows_for, permission_template: permission_template)
    # add deposit rights for registered users here if required
  end

  example 'administrative deposit', :aggregate_failures do
    login_as(admin_user)
    visit hyrax.dashboard_path
    click_on 'Works'
    click_on 'Add New Work'
    choose 'Publication'
    click_button 'Create work'
    expect(page).to have_content('New Publication')
    fill_in id: 'publication_title', with: 'My new Publication'
    fill_in id: 'publication_series', with: 'Staff Reports'
    choose 'publication_visibility_open'
    click_on 'Files'
    find(id: 'addfiles', visible: :any).attach_file('spec/fixtures/files/tiny.txt')
    check 'agreement'

    # Yield control back to the browser until the Javascript upload completes
    # i.e. there is a delete button next to the uploaded file
    page.find('tbody.files') until page.find('button.delete')
    click_on 'Save'

    # Yield control back to the browser until the page redirects to the Publication view
    page.find(id: 'with_files_submit') until page.find('.work-title-wrapper span[itemprop="name"]')
    # The page should redirect to the newly created Publication
    expect(current_path).to match(hyrax_publication_path(Publication.last))
    expect(page).to have_content('My new Publication')
    expect(page).to have_selector('span.badge', text: 'Public')
    edit_link = page.find_link('Edit')['href']
    expect(edit_link).to match edit_hyrax_publication_path(Publication.last)
  end
end
