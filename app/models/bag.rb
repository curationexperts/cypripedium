# frozen_string_literal: true

require 'bagit'
require 'stringio'
require 'rubygems'
require 'zip'
require 'fileutils'
require 'find'

# A class for creating a zipped bag when given a work id
class Bag
  attr_reader :bag_path, :bag

  # @param work_id [Array<String>]
  # @param time_stamp [String]
  def initialize(work_ids:, time_stamp:)
    @work_ids = work_ids
    @time_stamp = time_stamp
    @bag_path = "#{Rails.application.config.bag_path}/mpls_fed_research_#{@time_stamp}"
    @bag = BagIt::Bag.new(@bag_path)
  end

  def create
    @work_ids.each do |work_id|
      @work_file_sets = ActiveFedora::Base.find(work_id).file_sets
      @work_file_sets.each do |work_file_set|
        work_file_set.files.each do |work_file|
          work_file.file_name.first.empty? { next }
          @bag.add_file("#{work_id}/#{work_file.file_name.first}") do |io|
            io.set_encoding Encoding::BINARY
            io.write work_file.content
          end
        end
      end
    end

    @bag.manifest!(algo: 'sha256')
    zip
    remove_bag
  end

  def zip
    zip_name = "#{@bag_path}.zip"
    src = @bag_path.to_s

    Zip::File.open(zip_name, Zip::File::CREATE) do |zip_file|
      ::Find.find(*src) do |file|
        relative_path = file.sub(@bag_path.to_s, "mpls_fed_research_#{@time_stamp}")
        zip_file.add(relative_path, File.new(file))
      end
    end
  end

  def remove_bag
    FileUtils.rm_rf(@bag.bag_dir)
  end
end
