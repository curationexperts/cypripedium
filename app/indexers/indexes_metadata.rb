# frozen_string_literal: true

module IndexesMetadata
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['title_ssi'] = object.title.first
      solr_doc['date_created_ssi'] = object.date_created.first
      creator_names = object.creator_id.map do |id|
        Creator.find(id).display_name
      end
      solr_doc['creator_tesim'] = creator_names
      solr_doc['alpha_creator_tesim'] = creator_names.sort
    end
  end
end
