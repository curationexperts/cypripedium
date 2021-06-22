# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::ImagePresenter do
  let(:presenter) { described_class.new(solr_document, ability, request) }

  let(:solr_document) { SolrDocument.new(id: '123') }
  let(:ability) { nil }
  let(:request) { nil }

  it_behaves_like 'a work presenter'
end
