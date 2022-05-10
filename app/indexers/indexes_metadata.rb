# frozen_string_literal: true

module IndexesMetadata
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['title_ssi'] = object.title.first
      solr_doc['date_created_ssi'] = object.date_created.first
      solr_doc['date_created_iti'] = extract_year_from_date_created
      solr_doc['creator_tesim'] = creator_alternate_names(object).to_a + creator_names(object).to_a
      solr_doc['alpha_creator_tesim'] = creator_names(object).sort
      solr_doc['creator_sim'] = creator_names(object)
      solr_doc['creator_id_ssim'] = creator_numerical_ids(object) if creator_numerical_ids(object)
    end
  end

  def creator_names(object)
    @creator_names ||= if object.creator_id.present?
                         creator_numerical_ids(object).flat_map do |creator_id|
                           Creator.find_by(id: creator_id)&.display_name
                         end.reject(&:blank?)
                       else
                         object.creator
                       end
  end

  def creator_alternate_names(object)
    @creator_alternate_names ||= if object.creator_id.present?
                                   creator_numerical_ids(object).flat_map do |creator_id|
                                     Creator.find_by(id: creator_id)&.alternate_names
                                   end.reject(&:blank?)
                                 else
                                   object.creator.flat_map do |name|
                                     Creator.find_by(display_name: name)&.alternate_names
                                   end.reject(&:blank?)
                                 end
  end

  def creator_numerical_ids(object)
    @creator_numerical_ids ||= if object.creator_id.present?
                                 object.creator_id.map do |identifier|
                                   identifier.to_s
                                   # URI(creator_triple.id).path.split('/').last
                                 end
                               end
  end

  # Looks for the first sequence of four digits in a row in date_created
  # and returns them as an integer
  def extract_year_from_date_created
    year = object.date_created.first&.match(/\d{4}/)
    year.to_s.to_i if year
  end
end
