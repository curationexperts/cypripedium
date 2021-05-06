# frozen_string_literal: true

module IndexesMetadata
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['title_ssi'] = object.title.first
      solr_doc['date_created_ssi'] = object.date_created.first
      solr_doc['creator_tesim'] = creator_alternate_names(object).to_a + creator_names(object).to_a
      solr_doc['alpha_creator_tesim'] = creator_names(object).sort
      solr_doc['creator_sim'] = creator_names(object)
      solr_doc['creator_id_ssim'] = creator_numerical_ids(object) if creator_numerical_ids(object)
    end
  end

  def creator_names(object)
    @creator_names ||= if object.creator_id.present?
                         creator_numerical_ids(object).map do |creator_id|
                           Creator.find(creator_id).display_name
                         end
                       else
                         object.creator
                       end
  end

  def creator_alternate_names(object)
    @creator_alternate_names ||= if object.creator_id.present?
                                   creator_numerical_ids(object).flat_map do |creator_id|
                                     Creator.find(creator_id).alternate_names
                                   end
                                 else
                                   object.creator.flat_map do |name|
                                     Creator.find_by(display_name: name)&.alternate_names
                                   end
                                 end
  end

  def creator_numerical_ids(object)
    @creator_numerical_ids ||= if object.creator_id.present?
                                 object.creator_id.map do |creator_triple|
                                   URI(creator_triple.id).path.split('/').last
                                 end
                               end
  end
end
