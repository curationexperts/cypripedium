# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'catalog/_index_list_default.html.erb', type: :view do
  before do
    # Stub methods required by view that are typically provided by the CatalogController
    without_partial_double_verification do
      allow(view).to receive(:blacklight_config).and_return(CatalogController.blacklight_config)
      allow(view).to receive(:blacklight_configuration_context).and_return(Blacklight::Configuration::Context.new(controller))
      allow(view).to receive(:search_state).and_return(CatalogController.search_state_class.new(params, view.blacklight_config, controller))
      allow(view).to receive(:search_action_path).and_return('http://example.com/catalog/[facet_search]/')
    end
  end

  let(:document) {
    SolrDocument.new(alpha_creator_tesim: ['author, first', 'Creator, Second', 'Originator, Third'])
  }

  it 'separates creators with semicolons' do
    render 'catalog/index_list_default', document: document
    expect(rendered).to have_selector('tr.creator td',
                                      exact_text: 'author, first; Creator, Second; and Originator, Third')
  end
end
