# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImagePresenter < Hyrax::WorkShowPresenter
    include ::Hyrax::HasZip

    Attributes.to_a.each { |term| delegate term, to: :solr_document }
    delegate :alpha_creator, to: :solr_document
  end
end
