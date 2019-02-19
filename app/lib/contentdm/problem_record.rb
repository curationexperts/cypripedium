# frozen_string_literal: true

require 'fileutils'

module Contentdm
  ##
  # This class is used for collection records that have
  # not imported sucessfully and then writing them to
  # to a file that can be used to re-import them at a
  # later time
  class ProblemRecord
    attr_accessor :doc, :file_name
    ##
    # @param [String, String] collection_name, file_name
    def initialize(collection_name, file_name)
      xml_string = %(
<metadata>
  <collection_name>#{collection_name}</collection_name>
</metadata>
)
      xml = if File.exist?(file_name)
              File.open(file_name, 'r')
            else
              xml_string
            end
      @doc = Nokogiri::XML(xml)
      @file_name = file_name
    end

    ##
    # @param [String] record
    def add_record(record)
      @doc.root.add_child(record)
    end

    def save_xml
      problem_record_file = File.open(@file_name, 'w')
      problem_record_file << @doc.to_xml
      problem_record_file.close
    end

    def clean_up
      FileUtils.rm([@file_name]) if @doc.xpath('//record').empty?
    end
  end
end
