# frozen_string_literal: true

require 'rdf/rdfxml'

class RdfXmlService
  attr_reader :graph_exporter
  def initialize(work_id:)
    solr_doc = SolrDocument.find(work_id)
    @graph_exporter =
      ::Hyrax::GraphExporter.new(
        solr_doc,
        hostname: Rails.application.config.rdf_uri
      )
  end

  def xml
    @graph_exporter.fetch.dump(:rdf)
  end
end
