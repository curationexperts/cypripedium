# frozen_string_literal: true

require 'rails_helper'
include Warden::Test::Helpers

# This spec should not create the directory where the bags
# are stored so that the bagging job will fail early.
# right now the directory will be created if the parent
# directory exists and there are permissions on the directory
# this spec creates a situation where the bag directory can't be
# created.
RSpec.describe 'Recieve an error notfication when creating a bag', type: :system, js: true do
  describe 'creating a notification when running a bag job' do
    let(:work_ids) { [1, 2] }
    let(:user) { FactoryBot.create(:admin) }

    before do
      AdminSet.find_or_create_default_admin_set_id
      login_as user
    end

    it 'creates an error notification' do
      BagJob.perform_now(work_ids: work_ids, user: user, compression: 'zip')
      visit '/notifications'
      expect(page).to have_content('error')
    end
  end
end
