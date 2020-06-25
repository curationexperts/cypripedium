# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  # Add a filter query to restrict the search to documents the current user has access to
  include Hydra::AccessControlsEnforcement
  include Hyrax::SearchFilters

  self.default_processor_chain += [:sort_by_issue_number_when_no_query]

  ##
  # Within a collection show page, we want items to be ordered by issue number.
  # So, if there is no query (solr_parameters["q"]), set the sort to issue number descending.
  # However, if there IS a query then don't change the sort order, let it stay
  # sorting by relevance.
  def sort_by_issue_number_when_no_query(solr_parameters)
    issue_number_sort = "issue_number_ssi desc, system_modified_dtsi desc"
    solr_parameters["sort"] = issue_number_sort if solr_parameters["q"].nil?
  end

  ##
  # @example Adding a new step to the processor chain
  #   self.default_processor_chain += [:add_custom_data_to_query]
  #
  #   def add_custom_data_to_query(solr_parameters)
  #     solr_parameters[:custom] = blacklight_params[:user_value]
  #   end
end
