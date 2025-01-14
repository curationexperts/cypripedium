# frozen_string_literal: true

# Remove the CollectionSearchBuilder method override that forces all requests to sort by title
# which causes the app to fallback to the base implementation in Blacklight::Solr::SearchBuilderBehavior
module Extensions
  module CollectionMemberSearchService
    def self.included(k)
      k.class_eval do
        def available_member_works
          sort_field = user_params[:sort]
          response, _docs = search_results do |builder|
            builder.search_includes_models = :works
            builder.merge(sort: sort_field) if sort_field
            builder
          end
          response
        end
      end
    end
  end
end
