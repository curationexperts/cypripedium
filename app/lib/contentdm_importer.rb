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
    # TODO: How to know whether a work is a Publication, DataSet, ConferenceProceeding, etc?
    work = Publication.new
    work.title = titles(record)
    work.creator = creators(record)
    work.save
    work
  end

  # Return an array of titles for a given record
  # @param [] record
  # @return Array
  def titles(record)
    return_array = []
    record.xpath(".//title").each do |a|
      return_array << a.text
    end
    return_array.reject(&:empty?)
  end

  # Return an array of creators for a given record
  # @param [] record
  # @return Array
  def creators(record)
    return_array = []
    record.xpath(".//creator").each do |a|
      return_array << a.text
    end
    return_array.reject(&:empty?)
  end
end
