# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::CollectionSearchBuilder do
  subject(:builder) { described_class.new(scope) }
  let(:scope) { Hyrax::CollectionsController.new }

  describe '#add_sorting_to_solr' do
    let(:builder) { described_class.new(scope).with(blacklight_params) }
    let(:blacklight_params) do
      { "sort" => "system_create_dtsi desc" }.with_indifferent_access
    end
    let(:solr_parameters) { {} }

    before { builder.add_sorting_to_solr(solr_parameters) }

    it 'sets the solr paramters for sorting correctly' do
      expect(solr_parameters[:sort]).to eq('system_create_dtsi desc')
    end
  end
end
