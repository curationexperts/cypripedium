# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CypripediumIndexer, clean: true do
  let(:pub_indexer) { described_class.new(publication) }
  let(:data_indexer) { described_class.new(dataset) }
  let(:conf_indexer) { described_class.new(conference_proceeding) }
  let(:publication) { Publication.new(attrs) }
  let(:dataset) { Dataset.new(attrs) }
  let(:conference_proceeding) { ConferenceProceeding.new(attrs) }
  let(:data_doc) { data_indexer.generate_solr_document }
  let(:conf_doc) { conf_indexer.generate_solr_document }

  describe '#generate_solr_document' do
    context "with Creators from the authority records" do
      let(:solr_doc) { pub_indexer.generate_solr_document }

      let(:creator_one) { FactoryBot.create(:creator, display_name: 'Kehoe, Patrick J.') }
      let(:creator_two) { FactoryBot.create(:creator, display_name: 'Backus, David', alternate_names: ['Backus, Davey', 'Backus-Up, David']) }
      let(:creator_three) { FactoryBot.create(:creator, display_name: 'Kehoe, Timothy J.') }

      let(:attrs) {
        { title: ['My Title'],
          date_created: ['1970-04'],
          creator_id: [creator_one.authority_rdf, creator_two.authority_rdf, creator_three.authority_rdf] }
      }
      it 'indexes a sortable title and date created' do
        expect(solr_doc['title_ssi']).to eq 'My Title'
        expect(solr_doc['date_created_ssi']).to eq '1970-04'
        # The problem with storing them separately in Fedora is that it looks like they get re-ordered in Solr
        # Wait! But with Fedora we have to totally write over the whole array anyway, so if we find the ID in
        # the creator_id array we can replace the whole set of creator names
        creator_id_array = solr_doc['creator_id_ssim']
        expect(creator_id_array).to include creator_one.id.to_s
        expect(creator_id_array).to include creator_two.id.to_s
        expect(creator_id_array).to include creator_three.id.to_s
        creator_array = solr_doc['creator_tesim']
        expect(creator_array).to include 'Kehoe, Patrick J.'
        expect(creator_array).to include 'Backus, David'
        expect(creator_array).to include 'Backus, Davey'
        expect(creator_array).to include 'Backus-Up, David'
        expect(creator_array).to include 'Kehoe, Timothy J.'
      end
      it 'indexes the creator names in alphabetical order' do
        expect(solr_doc['alpha_creator_tesim']).to eq ['Backus, David', 'Kehoe, Patrick J.', 'Kehoe, Timothy J.']
      end
      it 'indexes for the facet' do
        expect(solr_doc['creator_sim']).to match_array(["Kehoe, Timothy J.", "Backus, David", "Kehoe, Patrick J."])
      end
      it 'indexes a dataset' do
        expect(data_doc['title_ssi']).to eq 'My Title'
        expect(data_doc['date_created_ssi']).to eq '1970-04'
        creator_id_array = data_doc['creator_id_ssim']
        expect(creator_id_array).to include creator_one.id.to_s
        expect(creator_id_array).to include creator_two.id.to_s
        expect(creator_id_array).to include creator_three.id.to_s
        creator_array = data_doc['creator_tesim']
        expect(creator_array).to include 'Kehoe, Patrick J.'
        expect(creator_array).to include 'Backus, David'
        expect(creator_array).to include 'Backus, Davey'
        expect(creator_array).to include 'Backus-Up, David'
        expect(creator_array).to include 'Kehoe, Timothy J.'
      end
      it 'indexes a conference proceeding' do
        expect(conf_doc['title_ssi']).to eq 'My Title'
        expect(conf_doc['date_created_ssi']).to eq '1970-04'
        creator_id_array = conf_doc['creator_id_ssim']
        expect(creator_id_array).to include creator_one.id.to_s
        expect(creator_id_array).to include creator_two.id.to_s
        expect(creator_id_array).to include creator_three.id.to_s
        creator_array = conf_doc['creator_tesim']
        expect(creator_array).to include 'Kehoe, Patrick J.'
        expect(creator_array).to include 'Backus, David'
        expect(creator_array).to include 'Backus, Davey'
        expect(creator_array).to include 'Backus-Up, David'
        expect(creator_array).to include 'Kehoe, Timothy J.'
      end
    end

    context 'with old data without creator ids' do
      let(:solr_doc) { pub_indexer.generate_solr_document }

      let(:attrs) {
        { title: ['My Title'],
          date_created: ['1970-04'],
          creator: ['Kehoe, Patrick J.', 'Backus, David', 'Kehoe, Timothy J.'] }
      }
      it 'indexes the creator names in alphabetical order' do
        expect(solr_doc['alpha_creator_tesim']).to eq ['Backus, David', 'Kehoe, Patrick J.', 'Kehoe, Timothy J.']
      end
    end
  end
end
