# frozen_string_literal: true

module Hyrax
  class CitationPresenter < Hyrax::WorkShowPresenter
    include ::Hyrax::HasZip

    delegate :alpha_creator, :corporate_name, :issue, :parent_collection, :doi, :creator, :series, to: :solr_document
  end
end
