require 'find'

module Hyrax
  class WorkBag
    attr_reader :bag_path, :bag, :work_id

    # @param work_id [Array<String>]
    # @param time_stamp [String]
    def initialize(work_ids:, time_stamp:)
      @work_ids = work_ids
      @time_stamp = time_stamp
      @bag_path = "#{Rails.application.config.bag_path}/#{Rails.application.config.bag_prefix}_#{@time_stamp}"
      create_bag_storage_dir
      @bag = BagIt::Bag.new(@bag_path)
    end

    def create
      @work_ids.each do |work_id|
        @work_id = work_id
        write_metadata_content
        write_file_content
      end
      @bag.manifest!(algo: 'sha256')
      compress
    end

    def remove
      FileUtils.rm_rf(@bag.bag_dir)
    end

    def compress
      raise 'Not yet implemented'
    end

    def work_count
      Set.new(@bag.paths.map { |path| path.split('/')[0] }).length
    end

    private

      def create_bag_storage_dir
        FileUtils.mkdir(Rails.application.config.bag_path) unless File.exist?(Rails.application.config.bag_path)
      end

      def metadata_content
        rdf_xml_service = RdfXmlService.new(work_id: @work_id)
        rdf_xml_service.xml
      end

      def write_metadata_content
        @bag.add_file("#{@work_id}/#{@work_id}.xml") do |io|
          io.write metadata_content
        end
      end

      def write_file_content
        @work_file_sets = ActiveFedora::Base.find(@work_id).file_sets
        @work_file_sets.each do |work_file_set|
          work_file_set.files.each do |work_file|
            next if work_file.file_name.first.empty?
            @bag.add_file("#{@work_id}/#{work_file.file_name.first}") do |io|
              io.set_encoding Encoding::BINARY
              io.write work_file.content
            end
          end
        end
      end
  end
end
