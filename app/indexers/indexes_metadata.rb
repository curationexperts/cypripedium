module IndexesMetadata
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['title_ssi'] = object.title.first
    end
  end
end
