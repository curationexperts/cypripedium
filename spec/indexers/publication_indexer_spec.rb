# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PublicationIndexer do
  let(:indexer) { described_class.new(publication) }
  let(:publication) { Publication.new(attrs) }
  let(:attrs) { { title: ['My Title'], date_created: ['1970-04'] } }

  describe '#generate_solr_document' do
    let(:solr_doc) { indexer.generate_solr_document }

    it 'indexes a sortable title and date created' do
      expect(solr_doc['title_ssi']).to eq 'My Title'
      expect(solr_doc['date_created_ssi']).to eq '1970-04'
    end
  end
end
