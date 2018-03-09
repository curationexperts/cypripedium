# Generated via
#  `rails generate hyrax:work Dataset`
module Hyrax
  class DatasetPresenter < Hyrax::WorkShowPresenter
    include ::Hyrax::HasZip

    Attributes.to_a.each { |term| delegate term, to: :solr_document }
  end
end
