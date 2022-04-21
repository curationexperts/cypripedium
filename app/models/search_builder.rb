# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder

  # Add a filter query to restrict the search to documents the current user has access to
  include Hydra::AccessControlsEnforcement
  include Hyrax::SearchFilters

  self.default_processor_chain += [:sort_by_issue_number_when_no_query]

  ##
  # Within a collection show page, we want items to be ordered by issue number.
  # So, if there is no query (@blacklight_params[:q]), set the sort to issue number
  # descending.
  # However, if there IS a query or an explicit sort parameter then don't change
  # the sort order.
  def sort_by_issue_number_when_no_query(solr_parameters)
    return unless @blacklight_params[:controller] == "hyrax/collections"
    issue_number_sort = "issue_number_ssi desc, system_modified_dtsi desc"
    solr_parameters["sort"] = issue_number_sort if @blacklight_params[:q].nil? && @blacklight_params[:sort].nil?
  end

  ##
  # @example Adding a new step to the processor chain
  #   self.default_processor_chain += [:add_custom_data_to_query]
  #
  #   def add_custom_data_to_query(solr_parameters)
  #     solr_parameters[:custom] = blacklight_params[:user_value]
  #   end
end
