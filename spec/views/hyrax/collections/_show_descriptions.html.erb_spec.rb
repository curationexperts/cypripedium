# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/collections/_show_descriptions.html.erb', type: :view do
  LICENSE_TEXT = "https://creativecommons.org/licenses/by-nc/4.0/"
  LICENSE_LINK_TEXT = "Creative Commons BY-NC Attribution-NonCommercial 4.0 International"

  context 'displaying a custom collection' do
    let(:collection) do
      {
        id: '999',
        "has_model_ssim" => ["Collection"],
        "title_tesim" => ["Title 1"],
        'date_created_tesim' => '2000-01-01',
        'license_tesim' => [LICENSE_TEXT]
      }
    end
    let(:ability) { double }
    let(:solr_document) { SolrDocument.new(collection) }
    let(:presenter) { Hyrax::CollectionPresenter.new(solr_document, ability) }

    before do
      allow(presenter).to receive(:total_items).and_return(2)
      assign(:presenter, presenter)
      render
    end

    it "draws the metadata fields for collection" do
      expect(rendered).to have_content 'Date Created'
      expect(rendered).to include('itemprop="dateCreated"')
      expect(rendered).to have_content 'Total items'
      expect(rendered).to have_content '2'
      expect(rendered).to have_selector "a", text: LICENSE_LINK_TEXT.to_s, count: 1
    end
  end
end
