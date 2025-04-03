# frozen_string_literal: true
class CypripediumSearchBuilder < Hyrax::CatalogSearchBuilder
  # Hyrax adds a default collection facet filter that significantly increases
  # the time Solr takes to process catalog requests.

  # Cypripedium does not display a collection facet, so we want to remove this
  # filter from the processor chain used in the CatalogController
  self.default_processor_chain.delete(:filter_collection_facet_for_access)
  self.default_processor_chain.delete(:show_works_or_works_that_contain_files)
  self.default_processor_chain.delete(:add_query_to_solr)
  self.default_processor_chain.delete(:show_only_active_records)
  self.default_processor_chain.uniq!
end
