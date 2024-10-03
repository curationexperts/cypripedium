# frozen_string_literal: true
require 'rubygems/package'

module Hyrax
  class TarBag < WorkBag
    def compress
      tar_file = "#{bag_path}.tar"
      File.open tar_file, 'wb' do |open_tar_file|
        write_tar(open_tar_file)
      end
    end

    private

    def relative_path(file)
      file.sub bag_path, "#{Rails.application.config.bag_prefix}_#{time_stamp}"
    end

    def write_dir_or_file(tar, file)
      if File.directory? file
        tar.mkdir relative_path(file), 0o755
      else
        write_internal_file(tar, file)
      end
    end

    BLOCK_SIZE = 102_400_0
    def write_internal_file(tar, file)
      tar.add_file relative_path(file), 0o755 do |tar_io|
        File.open file, 'rb' do |rio|
          while (buffer = rio.read(BLOCK_SIZE))
            tar_io.write buffer
          end
        end
      end
    end

    def write_tar(open_tar_file)
      Gem::Package::TarWriter.new open_tar_file do |tar|
        ::Find.find bag_path do |file|
          write_dir_or_file(tar, file)
        end
      end
    end
  end
end
