# frozen_string_literal: true

class ExportPackager
  # Writes the plain-directory export layout that ExportPackager compresses into a zip file
  class ZipWriter
    def initialize(archive_root)
      @archive_root = archive_root
      FileUtils.mkdir_p(archive_root)
    end

    # ZIP exports have no per-work metadata files; present for interface parity with BagWriter
    def write_item_metadata(work); end

    def write_content(path, file)
      full_path = File.join(@archive_root, path)
      FileUtils.mkdir_p(File.dirname(full_path))
      File.binwrite(full_path, file.content)
    end

    # Writes accumulated metadata to a root-level csv file
    # @param csv [String] CSV formatted data to be written
    def finalize(csv)
      File.write(File.join(@archive_root, ExportPackager::METADATA_FILENAME), csv)
    end
  end
end
