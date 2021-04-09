# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PublicationIndexer do
  let(:indexer) { described_class.new(publication) }
  let(:creator_one) { FactoryBot.create(:creator, display_name: 'Kehoe, Patrick J.') }
  let(:creator_two) { FactoryBot.create(:creator, display_name: 'Backus, David') }
  let(:creator_three)  { FactoryBot.create(:creator, display_name: 'Kehoe, Timothy J.') }
  let(:publication) { Publication.new(attrs) }
  let(:attrs) {
    { title: ['My Title'],
      date_created: ['1970-04'],
      # creator: ['Kehoe, Patrick J.', 'Backus, David', 'Kehoe, Timothy J.'],
      creator_id: [creator_one.id, creator_two.id, creator_three.id] }
  }
  describe '#generate_solr_document' do
    let(:solr_doc) { indexer.generate_solr_document }

    it 'indexes a sortable title and date created' do
      expect(solr_doc['title_ssi']).to eq 'My Title'
      expect(solr_doc['date_created_ssi']).to eq '1970-04'
      # The problem with storing them separately in Fedora is that it looks like they get re-ordered in Solr
      # Wait! But with Fedora we have to totally write over the whole array anyway, so if we find the ID in
      # the creator_id array we can replace the whole set of creator names
      creator_id_array = solr_doc['creator_id_isim']
      expect(creator_id_array).to include creator_one.id.to_s
      expect(creator_id_array).to include creator_two.id.to_s
      expect(creator_id_array).to include creator_three.id.to_s
      creator_array = solr_doc['creator_tesim']
      expect(creator_array).to include 'Kehoe, Patrick J.'
      expect(creator_array).to include 'Backus, David'
      expect(creator_array).to include 'Kehoe, Timothy J.'
    end
    it 'indexes the creator names in alphabetical order' do
      expect(solr_doc['alpha_creator_tesim']).to eq ['Backus, David', 'Kehoe, Patrick J.', 'Kehoe, Timothy J.']
    end
  end
end
