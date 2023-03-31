# frozen_string_literal: true

Hyrax::Statistics::Works::Count.class_eval do
  private

  def by_date_and_permission
    works_count = {}
    works_count[:collections] = {}
    works_total = query_service.find_by_date_created(start_date, end_date).get
    works_count[:total] = works_total.length
    works_total.each do |work|
      collection_names = work['member_of_collections_ssim']
      next if collection_names.blank?
      collection_names.each do |collection_name|
        works_count[:collections][collection_name] = [] if works_count[:collections][collection_name].blank?
        works_count[:collections][collection_name].push work
      end
    end
    works_public = query_service.find_public_in_date_range(start_date, end_date).get
    works_count[:public] = works_public.length
    works_registered = query_service.find_registered_in_date_range(start_date, end_date).get
    works_count[:registered] = works_registered.length
    works_count[:private] = works_count[:total] - (works_count[:registered] + works_count[:public])
    works_count
  end
end
