# frozen_string_literal: true

module IndexesMetadata
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['title_ssi'] = object.title.first
      solr_doc['date_created_ssi'] = object.date_created.first
      solr_doc['creator_tesim'] = creator_names(object)
      solr_doc['alpha_creator_tesim'] = creator_names(object).sort
      solr_doc['creator_sim'] = creator_names(object)
    end
  end

  def creator_names(object)
    @creator_names ||= if object.creator_id.present?
                         object.creator_id.map do |id|
                           Creator.find(id).display_name
                         end
                       else
                         object.creator
                       end
  end
end
