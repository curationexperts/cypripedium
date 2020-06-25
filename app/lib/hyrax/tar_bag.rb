# frozen_string_literal: true
require 'rubygems/package'

module Hyrax
  class TarBag < WorkBag
    attr_reader :tar, :mode, :size, :file, :relative_path
    BLOCK_SIZE = 102_400_0

    def compress
      tar_file = "#{@bag_path}.tar"
      File.open tar_file, 'wb' do |open_tar_file|
        write_tar(open_tar_file)
      end
    end

    private

    def file_metadata
      @mode = File.stat(@file).mode
      @size = File.stat(@file).size
      @relative_path = @file.sub @bag_path.to_s, "#{Rails.application.config.bag_prefix}_#{@time_stamp}"
    end

    def write_dir_or_file
      if File.directory? @file
        tar.mkdir @relative_path, @mode
      else
        write_internal_file
      end
    end

    def write_internal_file
      tar.add_file_simple @relative_path, @mode, @size do |tar_io|
        File.open @file, 'rb' do |rio|
          while (buffer = rio.read(BLOCK_SIZE))
            tar_io.write buffer
          end
        end
      end
    end

    def write_tar(open_tar_file)
      src = @bag_path.to_s
      Gem::Package::TarWriter.new open_tar_file do |tar|
        @tar = tar
        ::Find.find *src do |file|
          @file = file
          file_metadata
          write_dir_or_file
        end
      end
    end
  end
end
