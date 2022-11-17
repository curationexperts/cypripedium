# frozen_string_literal: true

Hyrax::CollectionSearchBuilder.class_eval do
  def add_sorting_to_solr(solr_parameters)
    return if solr_parameters[:q]
    sort = solr_parameters[:sort] ||= blacklight_params[:sort].presence || "#{sort_field} asc"
    puts '******* ' + sort
  end
end
