# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cypripedium::CitationFormatter do
  let(:citation) { presenter.chicago_citation }
  let(:presenter) { CypripediumWorkPresenter.new(solr_document, nil, request) }
  let(:request) { instance_double(ActionDispatch::Request, base_url: 'https://researchdatabase.minneapolisfed.org') }
  let(:solr_document) { SolrDocument.new(solr_data) }
  let(:solr_data) do
    # minimal metadata
    {
      "has_model_ssim": ["Publication"],
      "id": "br86b3634",
      "title_tesim": ["Expensed and Sweat Equity"],
      "alpha_creator_tesim": ["McGrattan, Ellen R.",
                              "Prescott, Edward C."],
      "date_created_tesim": ["2005-09"]
    }
  end

  describe '#chicago_citation' do
    it 'includes the authors' do
      expect(citation).to include 'McGrattan, Ellen R., and Edward C. Prescott'
    end

    it 'removes author dates and other extraneous info' do
      solr_data['alpha_creator_tesim'] =
        [" \tAvenancio-León, Carlos",           # non-printing character with UTF8 chars that should be kept
         "Carlstrom, Charles T., 1960-\n",      # birth date and non-printing character
         "Cole, Harold Linh, 1957-2057",        # birth and death dates
         "Juster, F. Thomas (Francis Thomas), 1926-", # initial expansion and birth date should be dropped
         "Kocherlakota, Narayana Rao, 1963- ",  # birth date
         "Wang, Ping, 1957 December 5-"]        # verbose birth
      expect(citation).to include 'Avenancio-León, Carlos, Charles T. Carlstrom, Harold Linh Cole, F. Thomas Juster, Narayana Rao Kocherlakota, and Ping Wang'
    end

    it 'uses the upload date if no creation date is provided' do
      solr_data.delete(:date_created_tesim)
      solr_data[:date_uploaded_dtsi] = '2018-04-20T15:37:15Z'
      expect(citation).to include('2018')
    end

    it 'supports season in creation date' do
      solr_data[:date_created_tesim] = '1994 Winter'
      expect(citation).to include('Winter 1994')
    end

    it 'converts months from numeric to alpha' do
      solr_data[:date_created_tesim] = '1988-06'
      expect(citation).to include('June 1988')
    end

    it 'displays "no date" if both date_created and dated_uploaded are empty' do
      solr_data.delete(:date_created_tesim)
      solr_data.delete(:date_uploaded_dtsi)
      expect(citation).to include('no date')
    end

    it 'uses the upload year if "date created" can not be parsed' do
      solr_data[:date_created_tesim] = '19xx'
      solr_data[:date_uploaded_dtsi] = '1995-07-10T11:23:45Z'
      expect(citation).to include('1995')
    end

    it 'provides the direct link if DOI does not exist' do
      solr_data.delete(:identifier_tesim)
      expect(citation).to include 'https://researchdatabase.minneapolisfed.org/concern/publications/br86b3634'
    end

    describe 'for working papers' do
      let(:solr_data) do
        # Working paper, multiple authors, doi in identifier
        {
          "has_model_ssim": ["Publication"],
          "id": "br86b3634",
          "series_tesim": ["Working paper (Federal Reserve Bank of Minneapolis. Research Department)"],
          "issue_number_isi": 636,
          "title_tesim": ["Expensed and Sweat Equity"],
          "resource_type_tesim": ["Research Paper"],
          "alpha_creator_tesim": ["McGrattan, Ellen R.",
                                  "Prescott, Edward C."],
          "publisher_tesim": ["Federal Reserve Bank of Minneapolis"],
          "date_created_tesim": ["2005-09"],
          "identifier_tesim": ["https://doi.org/10.21034/wp.636"]
        }
      end

      it 'includes the Issue Number' do
        expect(citation).to include('636')
      end

      it 'includes the DOI' do
        expect(citation).to include('doi')
      end

      it 'formats elements correctly' do
        expect(citation).to eq 'McGrattan, Ellen R., and Edward C. Prescott. “Expensed and Sweat Equity.” '\
                               'Working Paper 636. Federal Reserve Bank of Minneapolis, September 2005. '\
                               'https://doi.org/10.21034/wp.636.'
      end
    end

    describe 'for journal articles' do
      let(:solr_data) do
        # Journal article, multiple authors, doi
        {
          "has_model_ssim": ["Publication"],
          "id": "12579s459",
          "series_tesim": ["Quarterly review (Federal Reserve Bank of Minneapolis. Research Department)"],
          "volume_number_isi": 16,
          "issue_number_isi": 1,
          "title_tesim": ["Direct Investment: A Doubtful Alternative to International Debt"],
          "resource_type_tesim": ["Article"],
          "alpha_creator_tesim": ["Cole, Harold Linh, 1957-", "English, William B. (William Berkeley), 1960-"],
          "publisher_tesim": ["Federal Reserve Bank of Minneapolis"],
          "date_created_tesim": ["1992 Winter"],
          "identifier_tesim": ["https://doi.org/10.21034/qr.1612"]
        }
      end

      it 'italicizes the journal name' do
        expect(citation).to include('<i>Quarterly Review</i>')
      end

      it 'includes the volume number' do
        expect(citation).to include('16')
      end

      it 'includes the issue number' do
        expect(citation).to include('no. 1')
      end

      it 'includes the date' do
        expect(citation).to include('1992')
      end

      it 'formats elements correctly' do
        expect(citation).to eq 'Cole, Harold Linh, and William B. English. “Direct Investment: '\
          'A Doubtful Alternative to International Debt.” <i>Quarterly Review</i> 16, no. 1 (Winter 1992). '\
          'https://doi.org/10.21034/qr.1612.'
      end
    end

    describe 'for conference proceedings' do
      let(:solr_data) do
        # Conference proceeding, multiple authors
        {
          "has_model_ssim": ["ConferenceProceeding"],
          "id": "ks65hc256",
          "series_tesim": ["International perspectives on debt, growth, and business cycles"],
          "title_tesim": ["International Business Cycles"],
          "resource_type_tesim": ["Conference Proceeding"],
          "alpha_creator_tesim": ["Ahmed, Shaghil, 1959-",
                                  "Ickes, Barry William",
                                  "Wang, Ping, 1957 December 5-",
                                  "Yoo, Byung Sam, 1952-"],
          "date_created_tesim": ["1989-07"]
        }
      end

      it 'includes the conference name' do
        expect(citation).to include('International Perspectives on Debt, Growth, and Business Cycles')
      end

      it 'includes the conference sponsor' do
        expect(citation).to include('Federal Reserve Bank of Minneapolis')
      end

      it 'formats elements correctly' do
        expect(citation).to eq 'Ahmed, Shaghil, Barry William Ickes, Ping Wang, and Byung Sam Yoo. '\
            '“International Business Cycles.” Paper Presented at the International Perspectives on Debt, '\
            'Growth, and Business Cycles Conference, Federal Reserve Bank of Minneapolis, Minneapolis, MN, July 1989.'\
            ' https://researchdatabase.minneapolisfed.org/concern/conference_proceedings/ks65hc256.'
      end
    end

    describe 'for datasets' do
      let(:solr_data) do
        # Independent dataset
        {
          "has_model_ssim": ["Dataset"],
          "id": "6969z0838",
          "title_tesim": ["Railroad Stock Prices, 1834-1845."],
          "date_uploaded_dtsi": "2018-04-03T15:57:49Z",
          "resource_type_tesim": ["Dataset"],
          "alpha_creator_tesim": ["Weber, Warren E."],
          "publisher_tesim": ["Federal Reserve Bank of Minneapolis. Research Dept."]
        }
      end

      it 'lists independent datasets as belonging to the "Research Database"' do
        expect(citation).to include('Research Database')
      end

      it 'identifies supporting data' do
        solr_data["series_tesim"] = ["Staff report (Federal Reserve Bank of Minneapolis. Research Department)"]
        solr_data["issue_number_isi"] = 396
        expect(citation).to include('Supporting Data. Staff Report 396')
      end

      it 'formats elements correctly' do
        expect(citation).to eq 'Weber, Warren E. “Railroad Stock Prices, 1834-1845.” Research Database. '\
          'Federal Reserve Bank of Minneapolis. Research Dept., 2018. '\
          'https://researchdatabase.minneapolisfed.org/concern/datasets/6969z0838.'
      end
    end
  end

  describe 'unexpected errors' do
    it 'return a friendly message' do
      # e.g. unexpected birth date format
      solr_data['alpha_creator_tesim'] = ['Kocherlakota, Narayana Rao, b. 1963']
      expect(presenter.chicago_citation).to eq 'No citations found'
    end
  end
end
