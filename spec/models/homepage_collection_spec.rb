require 'rails_helper'

RSpec.describe HomepageCollection, type: :model do
  let(:solr) { Blacklight.default_index.connection }

  # Some collection records to add to solr
  let(:working_papers) do
    { id: '111',
      has_model_ssim: ['Collection'],
      title_ssim: ['Working Papers Archive'] }
  end

  let(:conf_proceedings) do
    { id: '222',
      has_model_ssim: ['Collection'],
      title_ssim: ['Conference Proceedings Archive'] }
  end

  let(:research_data) do
    { id: '333',
      has_model_ssim: ['Collection'],
      title_ssim: ['Research Data'] }
  end

  let(:weber) do
    { id: '444',
      has_model_ssim: ['Collection'],
      title_ssim: ['Warren E. Weber Historical Data Archives'] }
  end

  let(:antebellum) do
    { id: '555',
      has_model_ssim: ['Collection'],
      title_ssim: ['Antebellum U.S. State Bank Balance Sheets'] }
  end

  describe '::all' do
    subject(:solr_docs) { described_class.all }

    # The titles from the returned list of collection documents
    let(:collection_titles) { solr_docs.flat_map { |doc| doc['title_ssim'] } }

    context 'when the expected records exist in the solr index' do
      before do
        # Delete any existing records from solr and
        # add the collections we need for this test.
        solr.delete_by_query('*:*')
        solr.add([antebellum, weber, research_data, conf_proceedings, working_papers])
        solr.commit
      end

      it 'returns the SolrDocuments for the collections in the right order' do
        expect(collection_titles).to eq [
          'Working Papers Archive',
          'Conference Proceedings Archive',
          'Research Data',
          'Warren E. Weber Historical Data Archives',
          'Antebellum U.S. State Bank Balance Sheets'
        ]

        expect(solr_docs.map(&:class).uniq).to eq [SolrDocument]
      end
    end

    context 'when some of the collections are missing from the solr index' do
      before do
        # Delete any existing records from solr and
        # add the collections we need for this test.
        # Note that we are only adding some of the
        # collections, and the others will be missing.
        solr.delete_by_query('*:*')
        solr.add([antebellum, weber])
        solr.commit
      end

      it 'returns the collections that it can, but doesn\'t raise an error' do
        expect(collection_titles).to eq [
          'Warren E. Weber Historical Data Archives',
          'Antebellum U.S. State Bank Balance Sheets'
        ]
      end
    end

    context 'when it can\'t connect to solr, or some other problem happens' do
      before do
        allow(Blacklight.default_index.connection).to receive(:get).and_raise(Blacklight::Exceptions::ECONNREFUSED, 'there was an error')
      end

      it 'returns an empty array' do
        expect(solr_docs).to eq []
      end
    end
  end
end
