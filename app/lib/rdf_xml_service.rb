class RdfXmlService
  attr_reader :graph_exporter
  def initialize(work_id:)
    solr_doc = SolrDocument.find(work_id)
    @graph_exporter = ::Hyrax::GraphExporter.new(solr_doc, RequestShim.new({}))
  end

  def xml
    @graph_exporter.fetch.dump(:rdf)
  end
end
