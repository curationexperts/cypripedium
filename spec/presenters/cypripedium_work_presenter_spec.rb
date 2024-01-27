# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CypripediumWorkPresenter do
  let(:presenter) { described_class.new(solr_document, nil) }
  let(:solr_document) { SolrDocument.new(id: '123', has_model_ssim: ['Publication']) }

  it_behaves_like 'a work presenter'

  describe 'citation' do
    it 'renders in chicago format' do
      expect(presenter.chicago_citation).not_to be_blank
    end

    it 'renders in apa format' do
      expect(presenter.apa_citation).not_to be_blank
    end

    it 'renders in mla format' do
      expect(presenter.mla_citation).not_to be_blank
    end

    it 'displays custom citations using markdown' do
      allow(presenter).to receive(:bibliographic_citation).and_return(['custom _citation_', '**another** citation'])
      expect(presenter.chicago_citation).to include "<p>custom <em>citation</em></p>\n\n<p><strong>another</strong> citation</p>"
    end
  end
end
