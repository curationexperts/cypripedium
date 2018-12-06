# frozen_string_literal: true

class CollectionIndexer < Hyrax::CollectionWithBasicMetadataIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['title_ssim'] = object.title
    end
  end
end
