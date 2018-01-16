require 'nokogiri'

# An importer for ContentDM exported Metadata
class ContentdmImporter
  DATA_PATH = "#{::Rails.root}/data".freeze
  attr_reader :doc
  attr_reader :records
  def initialize
    @doc = File.open("#{DATA_PATH}/ContentDM_XML_Full_Fields.xml") { |f| Nokogiri::XML(f) }
    @records = @doc.xpath("//record")
  end

  # Class level method, to be called, e.g., from a rake task
  # @example
  #  ContentdmImporter.import
  def self.import
    ContentdmImporter.new.import
  end

  def import
    @records.each do |record|
      begin
        process_record(record)
      rescue
        Rails.logger.error "Could not import record #{record}"
      end
    end
  end

  def document_count
    @records.count
  end

  def process_record(record)
    cdm_record = ContentdmRecord.new(record)
    # TODO: How to know whether a work is a Publication, DataSet, ConferenceProceeding, etc?
    work = Publication.new
    work.title = cdm_record.title
    work.creator = cdm_record.creators
    work.save
    work
  end
end
