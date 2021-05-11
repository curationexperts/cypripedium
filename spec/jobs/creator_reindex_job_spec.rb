# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreatorReindexJob, type: :job do
  let(:publication) { FactoryBot.create(:populated_publication) }
  let(:creator1) { Creator.create(display_name: publication['creator'].first) }

  context 'running the job' do
    it 'calls the method to reindex the associated works' do
      allow(Creator).to receive(:find).with(creator1.id).and_return(creator1)
      expect(creator1).to receive(:reindex_associated_works)
      described_class.perform_now(creator1.id)
    end
  end
  context "describe updating a hyrax work after a creator has been edited", clean: true do
    let(:work) { FactoryBot.build(:populated_publication) }
    let(:solr) { Blacklight.default_index.connection }
    it "reindexes on save" do
      creator1 = Creator.create(id: 1, display_name: "McGrattan, Ellen R.")
      Creator.create(id: 2, display_name: "Prescott, Edward C.")
      work.save!
      response = solr.get 'select', params: { q: 'has_model_ssim:Publication' }
      expect(response['response']['docs'].first['creator_tesim']).to include "McGrattan, Ellen R."
      creator1.display_name = "Name, Some New"
      expect(creator1).to receive(:reindex_setup)
      creator1.save
      described_class.perform_now(creator1.id)
      response = solr.get 'select', params: { q: 'has_model_ssim:Publication' }
      expect(response['response']['docs'].first['creator_tesim']).to include "Name, Some New"
      expect(response['response']['docs'].first['creator_tesim']).not_to include "McGrattan, Ellen R."
    end
  end
end
