# frozen_string_literal: true

# This class creates a zip file that contains all the
# files that are attached to a work.
#
# You can find the path to the zip file by calling:
#   work_zip.file_path
#
# The ID for the background job that will create the zip file:
#   work_zip.job_id
#
# The ID of the work that is associated with this WorkZip record:
#   work_zip.work_id

class WorkZip < ApplicationRecord
  # rubocop:disable Layout/HashAlignment
  enum status: {
    unavailable:  0,
    queued:       1,
    working:      2,
    failed:       3,
    completed:    4
  }
  # rubocop:enable Layout/HashAlignment

  # Create a zip file that contains all the files
  # that are attached to the work record.
  def create_zip
    working!
    work = ActiveFedora::Base.find(work_id)
    files = work.file_sets.map { |file_set| file_set.original_file }
    file_names = files.map { |f| f.file_name.first }
    zip_file_name = File.join(path_root, file_name(work.title.first))
    FileUtils.mkdir_p path_root
    temps = [] # Keep track of temp files so we can delete them later

    Zip::File.open(zip_file_name, Zip::File::CREATE) do |zipfile|
      files.each_with_index do |file, i|
        name = new_file_name(file_names, file.file_name.first, i)
        temp_file = Tempfile.new(name)
        temp_file.binmode
        temp_file.write(file.content)
        temp_file.close
        temps << temp_file
        zipfile.add(name, temp_file)
      end
    end

    temps.each { |temp_file| temp_file.delete }
    self.file_path = zip_file_name
    self.status = 'completed'
    save!
  rescue
    failed!
  end

  def path_root
    ENV["CYPRIPEDIUM_ZIP_DIR"] || Rails.root.join('tmp', 'zip_exports')
  end

  def file_name(work_title)
    title = Shellwords.escape(work_title[0..30].gsub(/\s+/, ""))
    date = Date.today.strftime('%Y-%m-%d')
    "#{title}_#{date}.zip"
  end

  # The names of the files that are attached to the
  # work are not guaranteed to be unique.  If there
  # are two or more files with the same name, we'll
  # get Zip::EntryExistsError when we try to add the
  # files with duplicate names to the zip file.
  # To avoid that error, if we find a file name that
  # isn't unique, we'll add a number to the front of
  # the file name to make it distinct from the other
  # file names.
  #
  # @param names [Array<String>] The list of all the file names for files attached to this work
  # @param file_name [String] The file name for one file
  # @param counter [Integer] A loop counter that will be added to the file name to make it a unique name
  #
  # @return [String] The unique file name
  def new_file_name(names, file_name, counter)
    non_unique_filenames = names.uniq.select { |x| names.count(x) > 1 }
    if non_unique_filenames.include?(file_name)
      counter.to_s + '_' + file_name
    else
      file_name
    end
  end

  # @param id [String] The ID for the work
  # Returns the most recent WorkZip record for that work
  def self.latest(id)
    where(work_id: id).order(updated_at: :desc).limit(1)
  end
end
