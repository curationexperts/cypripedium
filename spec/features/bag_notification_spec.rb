# frozen_string_literal: true

require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Recieve a notfication when creating a bag', js: false do
  describe 'creating a notification when running a bag job' do
    let(:work_ids) { [publication.id, publication2.id] }
    let(:file_path) { Rails.application.config.bag_path }

    let(:pdf_file) do
      File.open(file_fixture('pdf-sample.pdf')) { |file| create(:file_set, content: file) }
    end

    let(:image_file) do
      File.open(file_fixture('sir_mordred.jpg')) { |file| create(:file_set, content: file) }
    end

    let(:publication) do
      create(:publication, title: ['My Publication'], file_sets: [pdf_file, image_file])
    end

    let(:publication2) do
      create(:publication, title: ['My Publication 2'], file_sets: [pdf_file, image_file])
    end

    let(:user_attributes) do
      { email: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end

    before do
      AdminSet.find_or_create_default_admin_set_id
      login_as user
      FileUtils.rm_rf(file_path)
      FileUtils.mkdir(Rails.application.config.bag_path)
    end

    after do
      FileUtils.rm_rf(file_path)
    end

    it 'creates a notification' do
      BagJob.perform_now(work_ids: work_ids, user: user)
      visit '/notifications'
      expect(page).to have_link('here')
      expect(page).to have_content('bag')
    end
  end
end
