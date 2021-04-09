# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PublicationIndexer do
  let(:indexer) { described_class.new(publication) }
  let(:publication) { Publication.new(attrs) }
  let(:attrs) {
    { title: ['My Title'],
      date_created: ['1970-04'],
      creator: ['Kehoe, Patrick J.', 'Backus, David', 'Kehoe, Timothy J.'],
      creator_id: [1234, 567, 8910] }
  }
  describe '#generate_solr_document' do
    let(:solr_doc) { indexer.generate_solr_document }

    it 'indexes a sortable title and date created' do
      expect(solr_doc['title_ssi']).to eq 'My Title'
      expect(solr_doc['date_created_ssi']).to eq '1970-04'
      # The problem with storing them separately in Fedora is that it looks like they get re-ordered in Solr
      # Wait! But with Fedora we have to totally write over the whole array anyway, so if we find the ID in
      # the creator_id array we can replace the whole set of creator names
      creator_array = solr_doc['creator_tesim']
      expect(creator_array).to include 'Kehoe, Patrick J.'
      expect(creator_array).to include 'Backus, David'
      expect(creator_array).to include 'Kehoe, Timothy J.'
      creator_id_array = solr_doc['creator_id_isim']
      expect(creator_id_array).to include "1234"
      expect(creator_id_array).to include "567"
      expect(creator_id_array).to include "8910"
    end
    it 'indexes the creator names in alphabetical order' do
      expect(solr_doc['alpha_creator_tesim']).to eq ['Backus, David', 'Kehoe, Patrick J.', 'Kehoe, Timothy J.']
    end
  end
end
