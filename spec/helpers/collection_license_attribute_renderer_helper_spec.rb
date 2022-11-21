# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers
include CollectionLicenseAttributeRendererHelper

RSpec.describe 'Edit markdown fields:', type: :system, js: true do
  COLLECTION_LICENSE_ATTRIBUTE_HTML = '<dt>License</dt><dd><a href=https://creativecommons.org/licenses/by-nc/4.0/ ' \
  'target="_blank">Creative Commons BY-NC Attribution-NonCommercial 4.0 International</a></dd>'
  COLLECTION_LICENSE_ATTRIBUTE_HTML_DISPLAY_MICRODATA = '<dt>License</dt><dd><span itemprop="name"><a href=https://creativecommons.org/licenses/' \
  'by-nc/4.0/ target="_blank">Creative Commons BY-NC Attribution-NonCommercial 4.0 International</a></span></dd>'

  context 'displaying a custom collection' do
    let(:collection) do
      {
        id: '999',
        "has_model_ssim" => ["Collection"],
        "title_tesim" => ["Title 1"],
        'date_created_tesim' => '2000-01-01',
        'license_tesim' => ["https://creativecommons.org/licenses/by-nc/4.0/"]
      }
    end
    let(:ability) { double }
    let(:solr_document) { SolrDocument.new(collection) }
    let(:presenter) { Hyrax::CollectionPresenter.new(solr_document, ability) }

    it 'veryfy the html output of a collection with display_microdata == false' do
      saved_display_microdata = Hyrax.config.display_microdata?
      Hyrax.config.display_microdata = false
      text = render_collection_license_attribute(presenter)
      expect(text).to eq COLLECTION_LICENSE_ATTRIBUTE_HTML
      Hyrax.config.display_microdata = saved_display_microdata
    end

    it 'veryfy the html output of a collection with a display_microdata == true' do
      text = render_collection_license_attribute(presenter)
      expect(text).to eq COLLECTION_LICENSE_ATTRIBUTE_HTML_DISPLAY_MICRODATA
    end
  end
end
