module IndexesMetadata
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['title_ssi'] = object.title.first
      solr_doc['date_created_ssi'] = object.date_created.first
    end
  end
end
