# Generated via
#  `rails generate hyrax:work DataSet`
module Hyrax
  class DataSetPresenter < Hyrax::WorkShowPresenter
    include ::Hyrax::HasZip

    Attributes.to_a.each { |term| delegate term, to: :solr_document }
  end
end
