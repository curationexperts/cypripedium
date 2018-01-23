# Generated via
#  `rails generate hyrax:work Publication`
module Hyrax
  class PublicationPresenter < Hyrax::WorkShowPresenter
    Attributes.to_a.each { |term| delegate term, to: :solr_document }
  end
end
