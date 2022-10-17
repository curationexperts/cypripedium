# frozen_string_literal: true

BlacklightRangeLimit::ControllerOverride.module_eval do
  def range_limit
    # We need to swap out the add_range_limit_params search param filter,
    # and instead add in our fetch_specific_range_limit filter,
    # to fetch only the range limit segments for only specific
    # field (with start/end params) mentioned in query params
    # range_field, range_start, and range_end

    @response, = search_results(params) do |search_builder|
      search_builder.except(:add_range_limit_params).append(:fetch_specific_range_limit)
    end
    render('blacklight_range_limit/range_segments', locals: { solr_field: params[:range_field] }, layout: !request.xhr?)
  end
end
