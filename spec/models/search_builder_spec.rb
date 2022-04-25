# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SearchBuilder do
  let(:search_builder) { described_class.new(context) }
  let(:blacklight_config) { CatalogController.blacklight_config.deep_copy }
  let(:context) { CatalogController.new }
  before { allow(context).to receive(:blacklight_config).and_return(blacklight_config) }

  describe "default processor chain" do
    let(:customized_processor_chain) do
      [
        :default_solr_parameters,
        :add_query_to_solr,
        :add_facet_fq_to_solr,
        :add_facetting_to_solr,
        :add_solr_fields_to_query,
        :add_paging_to_solr,
        :add_sorting_to_solr,
        :add_group_config_to_solr,
        :add_facet_paging_to_solr,
        :add_range_limit_params,
        :add_access_controls_to_solr_params,
        :filter_models,
        :only_active_works,
        :sort_by_issue_number_when_no_query
      ]
    end
    it "has the expected default processor chain" do
      expect(search_builder.processor_chain).to eq customized_processor_chain
    end
  end
end
