# frozen_string_literal: true
require 'rails_helper'
describe BulkDownloadController do
  include ActiveJob::TestHelper
  ActiveJob::Base.queue_adapter = :test

  after do
    clear_enqueued_jobs
  end

  let(:work) { FactoryBot.create(:publication) }
  let(:date) { Time.now.in_time_zone.strftime('%Y-%m-%d') }
  let(:title) { Shellwords.escape(work.title[0][0..30].gsub(/\s+/, "")) }
  let(:filename) { "#{title}_#{date}.zip" }
  describe 'GET #download' do
    it 'provides a download' do
      expect(BulkDownloadJob).to receive(:perform_now).once
      get :download, params: { id: work.id }
      expect(response.content_type.to_s).to match(/zip/)
      expect(response.header['Content-Disposition']).to include(filename)
    end
  end
end
