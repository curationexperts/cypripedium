# frozen_string_literal: true
require 'nokogiri'

# An importer for ContentDM exported Metadata
module Contentdm
  class Importer
    attr_reader :doc, :records
    attr_reader :input_file, :data_path, :default_work_model

    # @param input_file [String] the path to the XML file that contains the exported records from ContentDM.
    # @param data_path [String] the path to directory where the content files are located.
    # @param default_model [String] the type of work we want to create if the <work_type> isn't specified in the XML file.
    def initialize(input_file, data_path, default_model)
      @input_file = input_file
      @data_path = data_path
      @default_work_model = default_model
      @doc = File.open(input_file) { |f| Nokogiri::XML(f) }
      @records = @doc.xpath("//record")
      @collection = collection
    end

    # Class level method, to be called, e.g., from a rake task
    # @example
    # Contentdm::Importer.import('my_file.xml', 'path/to/data_dir', 'Publication')
    def self.import(input_file, data_path, default_model)
      Importer.new(input_file, data_path, default_model).import
    end

    def import
      @records.each do |record|
        begin
          work = process_record(record)
          Contentdm::Log.new("Adding #{work.id} to collection: #{collection_name}", 'info')
        rescue
          Contentdm::Log.new("Could not import record #{record})", 'error')
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
      work_type = work_model(cdm_record.work_type)
      Contentdm::Log.new("Creating new #{work_type} for #{cdm_record.identifier}", 'info')
      work = work_type.new
      work.title = cdm_record.title
      work.creator = cdm_record.creator
      work.contributor = cdm_record.contributor
      work.subject = cdm_record.subject
      work.description = cdm_record.description
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
    # @return [String] this returns the name of the folder that the collection's
    # files are stored in the folder specified during the import
    def collection_path
      collection_path = @doc.xpath("//collection_name").text.split(' ').join('_')
      "#{@data_path}/#{collection_path}"
    end

    ##
    # @return [ActiveFedora::Base] return the collection object
    def collection
      CollectionBuilder.new(collection_name).find_or_create
    end

    # Converts a class name into a class.
    # @param class_name [String] the type of work we want to create, 'Publication', 'ConferenceProceeding', or 'DataSet'.
    # @return [Class] return the work's class
    # @example If you pass in a string 'Publication', it returns the class ::Publication
    def work_model(class_name = nil)
      class_name ||= default_work_model
      class_name.constantize
    rescue NameError
      raise "Invalid work type: #{class_name}"
    end

    private

      def save_work(cdm_record, work)
        importer_user = ::User.batch_user
        current_ability = ::Ability.new(importer_user)
        uploaded_file = Contentdm::ImportFile.new(cdm_record, collection_path, importer_user).uploaded_file
        attributes = { uploaded_files: [uploaded_file.id] }
        env = Hyrax::Actors::Environment.new(work, current_ability, attributes)
        if Hyrax::CurationConcern.actor.create(env) != false
          Contentdm::Log.new("Saved work with title: #{cdm_record.title[0]}", 'info')
        else
          Contentdm::Log.new("Problem saving #{cdm_record.identifier}", 'error')
        end
      end
  end
end
