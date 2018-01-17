require 'nokogiri'

# An importer for ContentDM exported Metadata
module Contentdm
  class Importer
    attr_reader :doc
    attr_reader :records
    attr_reader :input_file
    def initialize(input_file)
      @input_file = input_file
      @doc = File.open(input_file) { |f| Nokogiri::XML(f) }
      @records = @doc.xpath("//record")
      @collection = collection
      @log = Importer.logger
    end

    # Class level method, to be called, e.g., from a rake task
    # @example
    # Contentdm::Importer.import
    def self.import(input_file)
      Importer.new(input_file).import
    end

    def self.logger
      Logger.new(STDOUT)
    end

    def import
      @records.each do |record|
        begin
          work = process_record(record)
          @log.info Rainbow("Adding #{work.id} to collection: #{collection_name}")
        rescue
          @log.error Rainbow("Could not import record #{record}
").red
          Rails.logger.error "Could not import record #{record}"
        end
      end
      @collection.save
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
      work.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      save_work(cdm_record, work)
      @collection.add_members(work.id)
      work
    end

    ##
    # @return [Array<String>] this returns the name of the collection based on the XML
    def collection_name
      [@doc.xpath("//collection_name").text]
    end

    ##
    # @return [ActiveFedora::Base] return the collection object
    def collection
      CollectionBuilder.new(collection_name).find_or_create
    end

    private

      def save_work(cdm_record, work)
        if work.save! != false
          @log.info Rainbow("Saved #{work.id}").green
          @log.info "Title: #{cdm_record.title[0]}"
        else
          @log.info Rainbow("Problem saving #{cdm_record.identifier}").red
        end
      end
  end
end
