# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreatorReindexJob, type: :job do
  context 'running the job' do
    it 'calls the method to reindex the associated works' do
      creator = FactoryBot.create(:creator)
      allow(Creator).to receive(:find).with(creator.id).and_return(creator)
      allow(creator).to receive(:reindex_associated_works)
      described_class.perform_now(creator.id)
      expect(creator).to have_received(:reindex_associated_works)
    end
  end

  context "editing a creator name", :clean, :aggregate_failures do
    let(:solr) { Blacklight.default_index.connection }
    let(:ellen_mcgrattan) { FactoryBot.create(:creator, display_name: 'McGrattan, Ellen R.') }

    before do
      @old_queue_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :test
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    end

    after do
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
      ActiveJob::Base.queue_adapter = @old_queue_adapter
    end

    it "reindexes associated works" do
      FactoryBot.create(:populated_publication, creators: [ellen_mcgrattan])
      response = solr.get 'select', params: { q: 'has_model_ssim:Publication' }
      expect(response['response']['docs'].first['creator_tesim']).to include 'McGrattan, Ellen R.'
      expect(response['response']['docs'].first['creator_tesim']).not_to include 'Some New Name'

      ellen_mcgrattan.display_name = 'Some New Name'
      expect do
        ellen_mcgrattan.save!
      end.to have_performed_job(described_class)

      response = solr.get 'select', params: { q: 'has_model_ssim:Publication' }
      expect(response['response']['docs'].first['creator_tesim']).to include 'Some New Name'
      expect(response['response']['docs'].first['creator_tesim']).not_to include 'McGrattan, Ellen R.'
    end
  end
end
