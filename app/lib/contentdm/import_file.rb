# frozen_string_literal: true

# This class looks for the file that will be imported
# in the data_path directory. It then creates a
# Hyrax::UploadedFile object by reading the file.
# This will be used in the importer to actually import
# the file with its metadata into Hyrax.
#
# The PDFs that are in that data_path folder should
# have a filename that is the same as the
# `<legacyFileName>` element in the CDM XML.
module Contentdm
  class ImportFile
    EXTENSION = '.zip'.freeze
    ##
    # @param record data_path user [Contentdm::Record, String, User]
    def initialize(record, data_path, user)
      @record = record
      @data_path = data_path
      @user = user
    end

    ##
    # this returns a Hyrax::Uploaded file object, that will be used when importing
    # @return [Hyrax::UploadedFile, nil]
    def uploaded_file
      return nil if @record.legacy_file_name.blank?
      if check_for_file(file_path)
        Contentdm::Log.new("Loading file: #{file_path}", 'info')
        Hyrax::UploadedFile.create(user: @user, file: File.open(file_path, 'r'))
      else
        Contentdm::Log.new("This file does not exist: #{file_path}", 'error')
      end
    end

    ##
    # @return [String]
    # this returns the full path to the PDF
    def file_path
      "#{@data_path}/#{@record.legacy_file_name}#{extension}"
    end

    ##
    # @return [String]
    # this returns the extension that is being used for the files
    def extension
      EXTENSION
    end

    def check_for_file(file_path)
      File.file?(file_path)
    end
  end
end
