# frozen_string_literal: true
require 'zip'

##
# This class is used to create a zip file
# of all the files in a FileSet
class BulkDownload
  attr_accessor :zip_file_name, :files
  ##
  # @param [String] ID for an ActiveFedora::Base work with FileSets
  # This zips up all the files in a FileSet object
  def initialize(work_id)
    work = ActiveFedora::Base.find(work_id)

    @files = work.file_sets.map { |file_set| file_set.files }
    @zip_file_name = Rails.root.join('tmp', Time.now.in_time_zone.to_a.join + '.zip')
    Zip::File.open(zip_file_name, Zip::File::CREATE) do |zipfile|
      @files.each do |file|
        temp_file = Tempfile.new(file[0].file_name[0])
        temp_file.binmode
        temp_file.write(file[0].content)
        temp_file.close
        begin
          zipfile.add(file[0].file_name[0], temp_file)
        rescue Zip::EntryExistsError
          Rails.logger.info "Attempted to add a duplicate file"
        end
      end
    end
  end

  ##
  # Returns the binary data for the file
  def read_zip
    File.open(zip_file_name, 'rb').read
  end
end
