# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'hyrax/base/_attribute_rows.html.erb', type: :view do
  let(:solr_data) do
    # minimal metadata
    {
      "has_model_ssim": ["Publication"],
      "id": "dummy_id",
      "title_tesim": ["Title"],
      "creator_tesim": ["anon. 21st Century"],
      "date_created_tesim": ["2024"]
    }
  end
  let(:solr_document) { SolrDocument.new(solr_data) }
  let(:request) { instance_double(ActionDispatch::Request, base_url: 'https://researchdatabase.minneapolisfed.org') }
  let(:presenter) { CypripediumWorkPresenter.new(solr_document, nil, request) }

  let(:partial) do
    render 'hyrax/base/attribute_rows', presenter: presenter
    # Capybara::Node::Simple.new(rendered) # supports capybara matchers
  end

  describe 'renders markdown' do
    example 'in description' do
      solr_data["description_tesim"] = ['A description with some **bold**, _italic_, and a link: https://example.org.']
      expect(partial).to include 'A description with some <strong>bold</strong>, <em>italic</em>, and a link: <a href="https://example.org">https://example.org</a>.'
    end

    example 'in abstract' do
      solr_data["abstract_tesim"] = ['An abstract with some [Markdown](https://commonmark.org/help/).']
      expect(partial).to include 'An abstract with some <a href="https://commonmark.org/help/">Markdown</a>'
    end

    example 'in related_url' do
      solr_data["related_url_tesim"] = ['A related URL with some _[Markdown](https://commonmark.org/help/)_.']
      expect(partial).to include 'A related URL with some <em><a href="https://commonmark.org/help/">Markdown</a></em>.'
    end

    example 'in bibliographic_citation' do
      solr_data["bibliographic_citation_tesim"] = ['A citation with some **[Markdown](https://commonmark.org/help/)**.']
      expect(partial).to include 'A citation with some <strong><a href="https://commonmark.org/help/">Markdown</a></strong>.'
    end
  end
end
