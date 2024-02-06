# frozen_string_literal: true

# Remove the CollectionSearchBuilder method override that forces all requests to sort by title
# which causes the app to fallback to the base implementation in Blacklight::Solr::SearchBuilderBehavior
module Extensions
  module CollectionSearchBuilder
    def self.included(k)
      k.class_eval do
        remove_method :add_sorting_to_solr
      end
    end
  end
end
