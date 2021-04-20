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
    @creator_names ||= object.creator.map do |triple_creator|
      if triple_creator.uri?
        creator_id = URI(triple_creator.id).path.split('/').last
        Creator.find(creator_id).display_name
      else
        triple_creator.id
      end
    end
  end
end
