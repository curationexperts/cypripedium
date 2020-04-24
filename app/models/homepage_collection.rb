# frozen_string_literal: true

# This class controls the list of collections that
# appear on the home page.

class HomepageCollection
  def self.collection_titles
    [
      'Staff Reports',
      'Working Papers',
      'Quarterly Review',
      'Institute Working Papers',
      'Discussion Papers',
      'Research Data',
      'Conference Proceedings Archive'
    ]
  end

  # Return a list of SolrDocuments for the collections.
  #
  # Note that we're using title_ssim (not title_tesim)
  # to make sure we exactly match the title.  If we
  # search with title_tesim, we might accidentally
  # find collections with similar titles.
  def self.all
    collection_titles.map do |title|
      query = "title_ssim:\"#{title}\""
      response = solr.get "select", params: { fq: [query], rows: 1 }
      record = response['response']['docs'].first
      next unless record
      SolrDocument.new(record)
    end.compact
  rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
    []
  end

  def self.solr
    Blacklight.default_index.connection
  end
end
