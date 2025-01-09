# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreatorReindexJob, type: :job do
  context 'running the job' do
    it 'calls the method to reindex the associated works' do
      creator = FactoryBot.build(:creator)
      allow(creator).to receive(:reindex_associated_works)
      described_class.perform_now(creator)
      expect(creator).to have_received(:reindex_associated_works)
    end
  end

  context "editing a creator name", :clean, :aggregate_failures do
    let(:solr) { Blacklight.default_index.connection }
    let(:creators) { [FactoryBot.create(:creator, display_name: 'McGrattan, Ellen R.')] }

    before do
      ActiveJob::Base.queue_adapter = :test
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    end

    it "re-indexes associated works" do
      publication = FactoryBot.create(:populated_publication, creators: creators)
      response = solr.get 'select', params: { q: 'has_model_ssim:Publication' }
      expect(response['response']['docs'].first['creator_tesim']).to include 'McGrattan, Ellen R.'
      expect(response['response']['docs'].first['creator_tesim']).not_to include "Name, Some New"

      creators.first.display_name = "Name, Some New"
      expect do
        creators.first.save
      end.to have_performed_job(described_class)

      response = solr.get 'select', params: { q: 'has_model_ssim:Publication' }
      expect(response['response']['docs'].first['creator_tesim']).to include "Name, Some New"
      expect(response['response']['docs'].first['creator_tesim']).not_to include 'McGrattan, Ellen R.'
    end
  end
end
