# frozen_string_literal: true

require 'bagit'
require 'stringio'
require 'rubygems/package'
require 'fileutils'

# A class for creating a tarred bag when given a work id
class Bag
  attr_reader :bag_path, :bag

  # @param work_id [Array<String>]
  # @param time_stamp [String]
  def initialize(work_ids:, time_stamp:)
    @work_ids = work_ids
    @time_stamp = time_stamp
    @bag_path = Rails.application.config.bag_path.join("mpls_fed_research.#{@time_stamp}")
    @bag = BagIt::Bag.new(@bag_path)
  end

  def create
    @work_ids.each do |work_id|
      @work_file_sets = ActiveFedora::Base.find(work_id).file_sets
      @work_file_sets.each do |work_file_set|
        work_file_set.files.each do |work_file|
          @bag.add_file("#{work_id}/#{work_file.file_name.first}") do |io|
            io.set_encoding Encoding::BINARY
            io.write work_file.content
          end
        end
      end
    end
    @bag.manifest!(algo: 'sha256')
    tar
    remove_bag
  end

  def tar
    block_size = 1024 * 1000
    tar_file = Rails.application.config.bag_path.join("mpls_fed_research.#{@time_stamp}.tar")
    src = @bag_path.to_s

    File.open tar_file, 'wb' do |open_tar_file|
      Gem::Package::TarWriter.new open_tar_file do |tar|
        Find.find *src do |file|
          relative_path = file.sub @bag_path.to_s, "mpls_fed_research.#{@time_stamp}"

          mode = File.stat(file).mode
          size = File.stat(file).size
          if File.directory? file
            tar.mkdir relative_path, mode
          else
            tar.add_file_simple relative_path, mode, size do |tar_io|
              File.open file, 'rb' do |rio|
                while (buffer = rio.read(block_size))
                  tar_io.write buffer
                end
              end
            end
          end
        end
      end
    end # end File.open
  end

  def remove_bag
    FileUtils.rm_rf(@bag.bag_dir)
  end
end
