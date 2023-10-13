# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Dataset`
module Hyrax
  class DatasetPresenter < Hyrax::WorkShowPresenter
    include ::Hyrax::HasZip

    CypripediumWork.added_attributes.each { |term| delegate term, to: :solr_document }
    delegate :alpha_creator, to: :solr_document
  end
end
