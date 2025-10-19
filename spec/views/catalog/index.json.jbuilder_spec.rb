# frozen_string_literal: true
require 'rails_helper'

# NOTE: These tests ensure catalog search results render JSON consistent with the
# expectations of the SiteCore interface. Cypripedium currently overrides Blacklight
# views/catalog/index.json.builder to provide backwards compatible view for SiteCore.
RSpec.describe "catalog/index.json", type: :view do
  let(:publication) { FactoryBot.build(:populated_publication, id: '0f1a2k3e4') }
  let(:dataset) { FactoryBot.build(:populated_dataset, id: '5f6a7k8e9') }
  let(:response) {
    instance_double(Blacklight::Solr::Response,
                                   documents: [solr_doc_for(publication), solr_doc_for(dataset)],
                                   current_page: 1,
                                   prev_page: nil,
                                   next_page: 2,
                                   total_pages: 2,
                                   total_count: 2,
                                   limit_value: 10,
                                   offset_value: 0,
                                   first_page?: true,
                                   last_page?: false)
  }
  let(:config) { CatalogController.blacklight_config }
  let(:presenter) { Blacklight::JsonPresenter.new(response, config) }

  let(:rendered_json) do
    render template: "catalog/index", formats: [:json]
    JSON.parse(rendered)
  end

  before do
    without_partial_double_verification do
      allow(view).to receive(:blacklight_config).and_return(config)
      allow(view).to receive(:blacklight_configuration_context).and_return(Blacklight::Configuration::Context.new(controller))
      allow(view).to receive(:search_state).and_return(CatalogController.search_state_class.new(params, view.blacklight_config, controller))
      allow(view).to receive(:search_action_path).and_return('http://test.host/some/search/url')
    end
    assign :presenter, presenter
  end

  it 'has the expected structure' do
    expect(rendered_json).to include(
      'response' => hash_including('docs', 'pages')
    )
  end

  it "has pagination information" do
    expect(rendered_json['response']['pages']).to include(
        'current_page' => 1,
        'next_page' => 2,
        'prev_page' => nil
      )
  end

  it "includes documents, links, and their attributes" do
    documents = rendered_json['response']['docs']
    expect(documents)
      .to include(
            hash_including(
              "id" => "0f1a2k3e4",
              "title_tesim" => publication.title,
              "resource_type_tesim" => ["Report"],
              "visibility_ssi" => "open"
            ),
            hash_including(
              "id" => "5f6a7k8e9",
              "title_tesim" => dataset.title,
              "resource_type_tesim" => ["Dataset"],
              "visibility_ssi" => "open"
            )
          )
  end

  def solr_doc_for(work)
    work.to_solr.select { |key, _value| key.match(/id|.*_tesim|.*_ssi|.*_ssim|.*_dtsi|.*_isi/) }
  end
end
