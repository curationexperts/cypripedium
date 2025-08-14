# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

# TODO: investigate turning this into a view spec
RSpec.describe 'dashboard', js: true do
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:admin) }

  context 'for guest users' do
    it 'redirects to login' do
      logout
      visit('dashboard')
      expect(page).to have_current_path(new_user_session_path)
    end
  end

  context 'for regular users' do
    before do
      login_as user
      visit('dashboard')
    end

    it 'has a works section' do
      expect(page).to have_link('Works', href: '/dashboard/my/works?locale=en')
    end

    it 'restricts admin-only menus' do
      expect(page).to have_no_selector('#dashboard-sidebar-reports')
    end
  end

  context 'for admin users' do
    before do
      login_as admin
      visit('dashboard')
    end

    it 'displays a reports menu' do
      expect(page).to have_selector('#dashboard-sidebar-reports')
    end

    # We need an engine routing test because Hrax namespaced controllers
    # don't access tenejo routes as expected
    it 'allows Hyrax controllers to access Cypripedium paths' do
      login_as admin
      expect { visit('dashboard/my/works') }.not_to raise_exception
      expect(page).to have_link(href: reports_path(locale: I18n.locale))
    end
  end
end
