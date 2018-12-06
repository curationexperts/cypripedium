# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CollectionIndexer do
  let(:indexer) { described_class.new(collection) }
  let(:collection) { Collection.new(attributes) }
  let(:attributes) { { title: ['Research Data'] } }

  describe '#generate_solr_document' do
    let(:solr_doc) { indexer.generate_solr_document }

    it 'indexes title_ssim' do
      expect(solr_doc['title_ssim']).to eq ['Research Data']
    end
  end
end
