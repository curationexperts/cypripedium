# frozen_string_literal: true
require 'nokogiri'

# An importer for ContentDM exported Metadata
module Contentdm
  class Importer
    attr_reader :doc, :records
    attr_reader :input_file, :data_path, :default_work_model

    # A place to collect the records that had errors during import
    attr_reader :problem_record, :problem_record_file_name

    # @param input_file [String] the path to the XML file that contains the exported records from ContentDM.
    # @param data_path [String] the path to directory where the content files are located.
    # @param default_model [String] the type of work we want to create if the <work_type> isn't specified in the XML file.
    def initialize(input_file, data_path, default_model)
      Validator.new(input_file).validate
      @input_file = input_file
      @data_path = data_path
      @default_work_model = default_model
      @doc = File.open(input_file) { |f| Nokogiri::XML(f) }
      @records = @doc.xpath("//record")
      @collection = collection

      @problem_record_file_name = "#{Time.now.in_time_zone.strftime('%v-%H:%M:%S')}_#{collection_name[0].split(' ').join('_')}.xml"
      @problem_record = Contentdm::ProblemRecord.new(collection_name[0], Rails.root.join('log', problem_record_file_name))
    end

    # Class level method, to be called, e.g., from a rake task
    # @example
    # Contentdm::Importer.import('my_file.xml', 'path/to/data_dir', 'Publication')
    def self.import(input_file, data_path, default_model)
      Importer.new(input_file, data_path, default_model).import
    end

    def import
      log_counts('Fedora record counts before import:')
      @records.each do |record|
        begin
          work = process_record(record)
          Contentdm::Log.new("Adding #{work.id} to collection: #{collection_name[0]}", 'info')
        rescue => e
          Contentdm::Log.new("Problem importing record #{record}: ERROR: #{e}", 'error')
          Contentdm::Log.new("Records that were unable to be imported will be saved at #{@problem_record_file_name}", 'error')
          rake_command = "rake import:contentdm -- -i #{@problem_record_file_name} -d #{data_path} -w #{default_work_model}"
          Contentdm::Log.new("To run again: ", 'error')
          Contentdm::Log.new(rake_command, 'error')
          @problem_record.add_record(record)
        end
      end
      @collection.save
      @problem_record.save_xml
      @problem_record.clean_up # Remove the problem record if there were no problems
      log_counts('Fedora record counts after import:')
    end

    def document_count
      @records.count
    end

    def process_record(record)
      cdm_record = Contentdm::Record.new(record)
      work_type = work_model(cdm_record.work_type)
      Contentdm::Log.new("Creating new #{work_type} for #{cdm_record.legacy_file_name}", 'info')
      work = work_type.new
      work.title = cdm_record.title
      work.creator = cdm_record.creator
      work.corporate_name = cdm_record.contributor
      work.subject = cdm_record.subject
      work.description = cdm_record.description
      work.requires = cdm_record.requires
      work.replaces = cdm_record.replaces
      work.abstract = cdm_record.abstract
      work.is_replaced_by = cdm_record.is_replaced_by
      work.table_of_contents = cdm_record.table_of_contents
      work.alternative_title = cdm_record.alternative_title
      work.series = cdm_record.series
      work.resource_type = cdm_record.resource_type
      work.identifier = cdm_record.identifier
      work.license = cdm_record.license
      work.publisher = cdm_record.publisher
      work.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      work.member_of_collections << @collection
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

    # Converts a class name into a class.
    # @param class_name [String] the type of work we want to create, 'Publication', 'ConferenceProceeding', or 'Dataset'.
    # @return [Class] return the work's class
    # @example If you pass in a string 'Publication', it returns the class ::Publication
    def work_model(class_name = nil)
      class_name ||= default_work_model
      class_name.constantize
    rescue NameError
      raise "Invalid work type: #{class_name}"
    end

    private

      def log_counts(first_msg)
        Contentdm::Log.new(first_msg, 'info')
        Contentdm::Log.new("   Conference Proceeding: #{ConferenceProceeding.count}", 'info')
        Contentdm::Log.new("   Data Set: #{Dataset.count}", 'info')
        Contentdm::Log.new("   Publication: #{Publication.count}", 'info')
        Contentdm::Log.new("   FileSet (attached files): #{FileSet.count}", 'info')
      end

      def save_work(cdm_record, work)
        importer_user = ::User.batch_user
        current_ability = ::Ability.new(importer_user)

        uploaded_file = Contentdm::ImportFile.new(cdm_record, data_path, importer_user).uploaded_file
        uploaded_file_id = uploaded_file.try(:id)
        attributes = { uploaded_files: [uploaded_file_id] }

        env = Hyrax::Actors::Environment.new(work, current_ability, attributes)
        if Hyrax::CurationConcern.actor.create(env) != false
          Contentdm::Log.new("Saved work with title: #{cdm_record.title[0]}", 'info')
        else
          Contentdm::Log.new("Problem saving #{cdm_record.legacy_file_name}", 'error')
        end
      end
  end
end
