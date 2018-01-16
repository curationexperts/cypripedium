require 'nokogiri'

# An importer for ContentDM exported Metadata
module Contentdm
  class Importer
    DATA_PATH = "#{::Rails.root}/data".freeze
    attr_reader :doc
    attr_reader :records
    def initialize
      @doc = File.open("#{DATA_PATH}/ContentDM_XML_Full_Fields.xml") { |f| Nokogiri::XML(f) }
      @records = @doc.xpath("//record")
      @log = Logger.new(STDOUT)
    end

    # Class level method, to be called, e.g., from a rake task
    # @example
    # Contentdm::Importer.import
    def self.import
      Importer.new.import
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
      cdm_record = Contentdm::Record.new(record)
      # TODO: How to know whether a work is a Publication, DataSet, ConferenceProceeding, etc?
      @log.info "Creating new Publication for #{cdm_record.identifer}"
      work = Publication.new
      work.title = cdm_record.title
      work.creator = cdm_record.creators
      work.contributor = cdm_record.contributors
      work.subject = cdm_record.subjects
      work.description = cdm_record.descriptions
      work.visibility = 'open'
      save_work(cdm_record, work)
      work
    end

    private

      def save_work(cdm_record, work)
        if work.save! != false
          @log.info Rainbow("Saved #{work.id}").green
          @log.info Rainbow("Title: #{cdm_record.title[0]}").green
        else
          @log.info Rainbow("Problem saving #{cdm_record.identifier}").red
        end
      end
  end
end
