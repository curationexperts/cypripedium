# Generated via
#  `rails generate hyrax:work ConferenceProceeding`
module Hyrax
  class ConferenceProceedingPresenter < Hyrax::WorkShowPresenter
    include ::Hyrax::HasZip

    Attributes.to_a.each { |term| delegate term, to: :solr_document }
  end
end
