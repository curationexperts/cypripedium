# frozen_string_literal: true

# Remove the CollectionSearchBuilder method override that forces all requests to sort by title
# which causes the app to fallback to the base implementation in Blacklight::Solr::SearchBuilderBehavior
module Fixes
  module AdminSetCreateService
    def self.included(k)
      k.class_eval do
        remove_const(:DEFAULT_ID) if const_defined?(:DEFAULT_ID)
        const_set(:DEFAULT_ID, 'admin_set/default')

        def create_admin_set(suggested_id:, title:)
          # Create a Hyrax 3.x compatible ActiveFedora-based AdminSet
          AdminSet.create!(id: suggested_id, title: Array.wrap(title))
          # Return a Hyrax 5.x compatible wrapper
          Hyrax.query_service.find_by(id: DEFAULT_ID)
        end
      end
    end
  end
end
