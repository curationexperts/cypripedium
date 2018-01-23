# frozen_string_literal: true

##
# This class is used to determine the path for the file that is imported from the
# collection name and the ID of a particular record in the XML.
# It then creates a Hyrax::UploadedFile object by reading the file. This will
# be used in the importer to actually import the file with its metadata into
# Hyrax.
#
# The files for import should be placed in the data directory in a sub-directory
# that has the same name as the collection. The name of that
# directory should have any spaces replaced with underscores. For example:
#
# `data/Sargent_and_Sims`
#
# The PDFs that are in that folder should have a filename that is the same as the
# `<identifier>` element in the CDM XML.
module Contentdm
  class ImportFile
    EXTENSION = '.pdf'.freeze
    ##
    # @param record collection_name user [Contentdm::Record, String, User]
    def initialize(record, collection_path, user)
      @record = record
      @collection_path = collection_path
      @user = user
    end

    ##
    # this returns a Hyrax::Uploaed file object, that will be used when importing
    # @return [Hyrax::UploadedFile]
    def uploaded_file
      if check_for_file(file_path)
        Contentdm::Log.new("Loading file: #{file_path}", 'info')
        Hyrax::UploadedFile.create(user: @user, file: File.open(file_path, 'r'))
      else
        Contentm::Log.new("This file does not exist: #{file_path}", 'error')
      end
    end

    ##
    # @return [String]
    # this returns the full path to the PDF
    def file_path
      "#{@collection_path}/#{@record.identifier}#{extension}"
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
