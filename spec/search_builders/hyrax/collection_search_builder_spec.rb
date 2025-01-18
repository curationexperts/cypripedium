# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::CollectionSearchBuilder do
  let(:builder) { described_class.new(scope).with(blacklight_params) }
  let(:scope) { Hyrax::CollectionsController.new }
  let(:blacklight_params) { { 'sort' => 'date_created_ssi desc' }.with_indifferent_access }

  example '#add_sorting_to_solr configures sorting correctly' do
    # NOTE: the sort field must match a sort defined in the CatalogController config
    solr_parameters = {}
    builder.add_sorting_to_solr(solr_parameters)
    expect(solr_parameters[:sort]).to eq('date_created_ssi desc')
  end
end
