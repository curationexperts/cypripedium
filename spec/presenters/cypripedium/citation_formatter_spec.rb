# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cypripedium::CitationFormatter do
  let(:presenter) { CypripediumWorkPresenter.new(solr_document, nil, request) }
  let(:request) { instance_double(ActionDispatch::Request, base_url: 'https://researchdatabase.minneapolisfed.org') }
  let(:solr_document) { SolrDocument.new(solr_data) }
  let(:solr_data) do
    # multiple authors, doi, working paper
    {
      "has_model_ssim": ["Publication"],
      "id": "br86b3634",
      "series_tesim": ["Working paper (Federal Reserve Bank of Minneapolis. Research Department)"],
      "issue_number_tesim": ["636"],
      "issue_number_ssi": "636",
      "depositor_tesim": ["batchuser@example.com"],
      "title_tesim": ["Expensed and Sweat Equity"],
      "date_uploaded_dtsi": "2019-06-25T13:40:30Z",
      "date_modified_ssi": "Wed Oct 23 17:51:43 2019",
      "resource_type_tesim": ["Research Paper"],
      "creator_tesim": ["McGrattan, Ellen R.",
                        "Prescott, Edward C."],
      "publisher_tesim": ["Federal Reserve Bank of Minneapolis"],
      "date_created_tesim": ["2005-09"],
      "identifier_tesim": ["https://doi.org/10.21034/wp.636"],
      "member_of_collections_ssim": ["New Working Papers",
                                     "Working Papers"],
      "title_ssi": "Expensed and Sweat Equity",
      "date_created_ssi": "2005-09",
      "human_readable_type_tesim": ["Publication"]
    }
  end

  describe '#chicago_citation' do
    let(:citation) { presenter.chicago_citation }
    it 'includes the authors' do
      expect(citation).to include 'McGrattan, Ellen R., and Edward C. Prescott'
    end

    it 'removes author dates and other extraneous info' do
      solr_data['creator_tesim'] =
        ["Kocherlakota, Narayana Rao, 1963- ",  # birth date
         "Carlstrom, Charles T., 1960-\n",      # birth date and non-printing character
         " \tAvenancio-León, Carlos",           # non-printing character with UTF8 chars that should be kept
         "Juster, F. Thomas (Francis Thomas), 1926-", # initial expansion and birth date should be dropped
         "Cole, Harold Linh, 1957-2057"] # birth and death dates
      expect(citation).to include 'Kocherlakota, Narayana Rao, Charles T. Carlstrom, Carlos Avenancio-León, F. Thomas Juster, and Harold Linh Cole'
    end

    it 'includes the DOI' do
      expect(citation).to include('doi')
    end

    it 'provides the direct repository link when no DOI is present' do
      solr_data.delete(:identifier_tesim)
      expect(citation).to include 'https://researchdatabase.minneapolisfed.org/concern/publications/br86b3634'
    end

    it 'includes the Issue Number' do
      expect(citation).to include('636')
    end

    it 'formats elements correctly' do
      expect(citation).to eq 'McGrattan, Ellen R., and Edward C. Prescott. “Expensed and Sweat Equity.” Working Paper 636. Federal Reserve Bank of Minneapolis, Minneapolis, MN, 2005. https://doi.org/10.21034/wp.636.'
    end
  end

  describe 'unexpected errors' do
    it 'return a friendly message' do
      # e.g. unexpected birth date format
      solr_data['creator_tesim'] = ['Kocherlakota, Narayana Rao, b. 1963']
      expect(presenter.chicago_citation).to eq 'No citations found'
    end
  end
end
