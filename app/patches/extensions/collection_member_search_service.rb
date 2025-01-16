# frozen_string_literal: true

# Override the #available_member_works
# default to sort by volume & issue number
# when no user supplied search sort parameters are present
module Extensions
  module CollectionMemberSearchService
    def self.included(k)
      k.class_eval do
        def available_member_works
          response, _docs = search_results do |builder|
            builder.search_includes_models = :works
            builder.merge(sort: preferred_sort)
            builder
          end
          response
        end

        def preferred_sort
          # the user supplied sort parameter takes precedence
          return user_params[:sort] if user_params[:sort].present?

          # otherwise relevance rank user searches
          return 'score desc, system_create_dtsi desc' if user_params[:q].present?

          # sort by volume and issue number when no user parameters are supplied
          'volume_number_isi desc, issue_number_isi desc, system_create_dtsi desc'
        end
      end
    end
  end
end
