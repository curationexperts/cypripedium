# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::CitationsBehaviors::Formatters::ChicagoFormatter do
  CITATION_TYPE_DATASET = '<span class="citation-author">Backus, David, Truman F. Bewley, Arnoud W. A. Boot, Charles T. ' \
  'Carlstrom, Patrick J. Kehoe, and G. Thomas Woodward.</span> ' \
  '<span class="citation-title">"My Title."&nbsp;</span>Research Database, Federal Reserve Bank of Minneapolis, 1970. ' \
  'https://researchdatabase.minneapolisfed.org/concern/datasets/ThisIsTest123.'

  CITATION_TYPE_JOURNAL = '<span class="citation-author">Backus, David, Truman F. Bewley, Arnoud W. A. Boot, Charles T. ' \
  'Carlstrom, Patrick J. Kehoe, and G. Thomas Woodward.</span> ' \
  '<span class="citation-title">"My Title."&nbsp;</span> <i class="citation-title">Collection 1 </i>1, no.1 (1970). https://doi.org/10.21034/xxxx.'

  CITATION_TYPE_BOOK = '<span class="citation-author">Backus, David, Truman F. Bewley, Arnoud W. A. Boot, Charles T. Carlstrom, Patrick J. Kehoe, and G. Thomas Woodward.</span> ' \
  '<i class="citation-title">My Title.</i> <span class="citation-author">Minneapolis,</span> <span class="citation-author">' \
  'MN</span>: Federal Reserve Bank of Minneapolis, 1970.'

  CITATION_TYPE_SOFTWARE = '<span class="citation-author">Backus, David, Truman F. Bewley, Arnoud W. A. Boot, Charles T. ' \
  'Carlstrom, Patrick J. Kehoe, and G. Thomas Woodward.</span> ' \
  '<span class="citation-title">"My Title."&nbsp;</span> Supporting data. In "Star Wars at Central Banks." Staff Report 620,  ' \
  'Federal Reserve Bank of Minneapolis, 1970.'

  CITATION_TYPE_CONFERENCE = '<span class="citation-author">Backus, David, Truman F. Bewley, Arnoud W. A. Boot, Charles T. ' \
  'Carlstrom, Patrick J. Kehoe, and G. Thomas Woodward.</span> ' \
  '<span class="citation-title">"My Title."&nbsp;</span>Paper presented at the Conference on Finance, Fluctuations, and Development, ' \
  'Federal Reserve Bank of Minneapolis, <span class="citation-author">Minneapolis,</span> <span class="citation-author">MN</span>, 1970.'

  CITATION_TYPE_CONFERENCE_WITHOUT_CONFERENCE_WORD = '<span class="citation-author">Backus, David, Truman F. Bewley, ' \
  'Arnoud W. A. Boot, Charles T. Carlstrom, Patrick J. Kehoe, and G. Thomas Woodward.</span> ' \
  '<span class="citation-title">"My Title."&nbsp;</span>Paper presented at the Research and Training in Computational Economics conference, ' \
  'Federal Reserve Bank of Minneapolis, <span class="citation-author">Minneapolis,</span> <span class="citation-author">MN</span>, 1970.'

  CITATION_TYPE_BOOK_PART = '<span class="citation-author">Backus, David, Truman F. Bewley, Arnoud W. A. Boot, ' \
  'Charles T. Carlstrom, Patrick J. Kehoe, and G. Thomas Woodward.</span> ' \
  '<span class="citation-title">"My Title."&nbsp;</span> In  <i class="citation-title">Great Depressions of the Twentieth Century</i>, ' \
  'edited by Timothy J. Kehoe and Edward C. Prescott.  <span class="citation-author">Minneapolis,</span> <span class="citation-author">MN</span>: ' \
  'Federal Reserve Bank of Minneapolis, 1970.'

  CITATION_TYPE_ARTICLE = '<span class="citation-author">Backus, David, Truman F. Bewley, Arnoud W. A. Boot, Charles T. ' \
  'Carlstrom, Patrick J. Kehoe, and G. Thomas Woodward.</span> ' \
  '<span class="citation-title">"My Title."&nbsp;</span> <i class="citation-title">Collection 1 </i>1, no.1 (1970). ' \
  'https://doi.org/10.21034/xxxx.'

  CITATION_TYPE_JOURNAL_NO_AUTHOR = '<span class="citation-author">Backus, David, Truman F. Bewley, Arnoud W. A. Boot, ' \
  'Charles T. Carlstrom, Patrick J. Kehoe, and G. Thomas Woodward.</span> ' \
  '<span class="citation-title">"My Title."&nbsp;</span>Research Database, Federal Reserve Bank ' \
  'of Minneapolis, 1970. https://researchdatabase.minneapolisfed.org/concern/datasets/ThisIsTest123.'

  subject(:formatter) { described_class.new(:no_context) }
  let(:admin_user) { FactoryBot.create(:admin) }
  let(:data_indexer) { CypripediumIndexer.new(dataset) }
  let(:dataset) { Dataset.new(attrs) }
  let(:data_doc) { data_indexer.generate_solr_document }

  describe '#generate_solr_document' do
    context "with Creators from the authority records" do
      let(:creator_one) { FactoryBot.create(:creator, display_name: 'Kehoe, Patrick J.') }
      let(:creator_two) { FactoryBot.create(:creator, display_name: 'Backus, David', alternate_names: ['Backus, Davey', 'Backus-Up, David']) }
      let(:creator_three) { FactoryBot.create(:creator, display_name: 'Kehoe, Timothy J.') }
      let(:collection) do
        coll = Collection.new(
          title: ['Collection 1'],
          collection_type: Hyrax::CollectionType.find_or_create_default_collection_type,
          description: ['Minneapolis city is amazing']
        )
        coll.apply_depositor_metadata(admin_user.user_key)
        coll.save!
        coll
      end

      let(:attrs) {
        { title: ['My Title'],
          date_created: ['1970-04-30'],
          creator: ['Kehoe, Patrick J.', 'Backus, David', 'Bewley, Truman F. (Truman Fassett), 1941-', \
                    'Boot, Arnoud W. A. (Willem Alexander), 1960-', 'Carlstrom, Charles T., 1960-', \
                    'Woodward, G. Thomas, 1953-'],
          related_url: ["Staff Report 620: Star Wars at Central Banks, https://doi.org/10.21034/sr.620\r\n\r\nStaff Report 621: Online Appendix: " \
                       "Star Wars at Central Banks, https://doi.org/10.21034/sr.621"],
          resource_type: [''],
          issue_number: ['Vol. 1, No. 1'],
          identifier: ['https://doi.org/10.21034/xxxx'],
          series: ['Conference on Finance, Fluctuations, and Development'],
          member_of_collections: [collection],
          corporate_name: ['Federal Reserve Bank of Minneapolis. Research Department'],
          publisher: ['Federal Reserve Bank of Minneapolis'],
          description: ['Chapter 6 of [_Great Depressions of the Twentieth Century_](https://doi.org/10.21034/mo.9780978936006), Timothy J. Kehoe and Edward C. Prescott, eds.'],
          id: 'ThisIsTest123' }
      }

      let(:presenter) { Hyrax::CitationPresenter.new(SolrDocument.new(data_doc), :no_ability) }

      it 'test citation of dataset resource type' do
        attrs['resource_type'] = ['Dataset']
        citation = formatter.format(presenter)
        expect(citation).to eq CITATION_TYPE_DATASET
      end

      it 'test citation of journal resource type' do
        attrs['resource_type'] = ['Journal']
        citation = formatter.format(presenter)
        expect(citation).to eq CITATION_TYPE_JOURNAL
      end

      it 'test citation of book resource type' do
        attrs['resource_type'] = ['Book']
        citation = formatter.format(presenter)
        expect(citation).to eq CITATION_TYPE_BOOK
      end

      it 'test citation of conference proceeding resource type' do
        attrs['resource_type'] = ['Conference Proceeding']
        citation = formatter.format(presenter)
        expect(citation).to eq CITATION_TYPE_CONFERENCE
      end

      # This is to test the conference info in series field does not contain the word "Conference"
      it 'test citation of conference proceeding resource type without word conference in description' do
        attrs['resource_type'] = ['Conference Proceeding']
        attrs['series'] = ['Research and Training in Computational Economics']
        citation = formatter.format(presenter)
        expect(citation).to eq CITATION_TYPE_CONFERENCE_WITHOUT_CONFERENCE_WORD
      end

      it 'test citation of part of book resource type' do
        attrs['resource_type'] = ['Part of Book']
        citation = formatter.format(presenter)
        expect(citation).to eq CITATION_TYPE_BOOK_PART
      end

      it 'test citation of research paper resource type' do
        attrs['resource_type'] = ['Research Paper']
        citation = formatter.format(presenter)
        expect(citation).to eq CITATION_TYPE_ARTICLE
      end

      it 'test citation of article resource type' do
        attrs['resource_type'] = ['Article']
        citation = formatter.format(presenter)
        puts citation
        expect(citation).to eq CITATION_TYPE_ARTICLE
      end

      it 'test citation of dissertation resource type' do
        attrs['resource_type'] = ['Dissertation']
        citation = formatter.format(presenter)
        expect(citation).to eq CITATION_TYPE_ARTICLE
      end

      it 'test citation of software or program code type' do
        attrs['resource_type'] = ['Software or Program Code']
        citation = formatter.format(presenter)
        expect(citation).to eq CITATION_TYPE_SOFTWARE
      end

      it 'test citation of poster resource type' do
        attrs['resource_type'] = ['Journal']
        citation = formatter.format(presenter)
        expect(citation).to eq CITATION_TYPE_ARTICLE
      end
    end
  end
end
