# frozen_string_literal: true
require 'csv'

class ExportJob < ApplicationJob
  METADATA_HEADERS = ['title', 'name-creator', 'name-author', 'dateCreated',
                      'dateModified', 'abstract', 'location-url',
                      'identifier', 'tableOfContents'].freeze

  SUPPORTED_TYPES = [Publication, Dataset, ConferenceProceeding].freeze

  def perform(export)
    @export = export
    @export.working!
    @metadata_rows = []

    Dir.mktmpdir do |tmp_dir|
      @bag = BagIt::Bag.new(File.join(tmp_dir, bag_name))
      build_bag
      write_metadata_csv
      zip_path = compress(tmp_dir)
      attach(zip_path)
    end

    @export.completed!
    notify(success: true)
  rescue StandardError => e
    @export.update!(status: :failed, message: e.message)
    notify(success: false)
  end

  private

  def bag_name
    "#{Rails.application.config.bag_prefix}_#{@export.id}"
  end

  def build_bag
    @export.items.each do |item_id|
      work = ActiveFedora::Base.find(item_id)
      add_item_to_bag(work)
    end
    @bag.manifest!(algo: 'sha256')
  end

  def write_metadata_csv
    @bag.add_file('metadata.csv') do |io|
      csv = CSV.new(io, headers: METADATA_HEADERS, write_headers: true)
      @metadata_rows.each { |row| csv << row }
    end
  end

  def location_url(work)
    type_path = work.class.to_s.underscore.pluralize
    "#{Rails.application.config.rdf_uri}/concern/#{type_path}/#{work.id}"
  end

  def add_item_to_bag(work)
    raise "Unsupported work type: #{work.class}" unless SUPPORTED_TYPES.include?(work.class)
    add_metadata_for_bag(work)
    add_files_to_bag(work)
  end

  def add_metadata_for_bag(work)
    @metadata_rows << [
      work.title.first,
      work.corporate_name.first,
      work.creator.sort.join('|'), # list creators in alphabetical order
      work.date_created.first,
      work.date_modified,
      work.abstract.first,
      location_url(work),
      work.identifier.first,
      work.table_of_contents.first
    ]
  end

  def add_files_to_bag(work)
    work.file_sets.each do |file_set|
      file_set.files.each do |file|
        next if file.file_name.first.empty?
        @bag.add_file("#{work.id}/#{file.file_name.first}") do |io|
          io.set_encoding Encoding::BINARY
          io.write file.content
        end
      end
    end
  end

  def compress(tmp_dir)
    zip_path = File.join(tmp_dir, "#{bag_name}.zip")
    bag_dir  = @bag.bag_dir

    Zip::File.open(zip_path, Zip::File::CREATE) do |zip|
      Find.find(bag_dir) do |file|
        relative_path = file.sub("#{tmp_dir}/", '')
        zip.add(relative_path, file)
      end
    end

    zip_path
  end

  def attach(zip_path)
    File.open(zip_path) do |file|
      @export.export_file.attach(
        io: file,
        filename: "#{bag_name}.zip",
        content_type: 'application/zip'
      )
    end
  end

  def notify(success:)
    return if @export.user.guest?
    subject = success ? 'Export completed' : 'Export failed'
    message = success ? success_message : failure_message
    @export.user.send_message(@export.user, message, subject)
  end

  # rubocop:disable Rails/OutputSafety
  def success_message
    <<~MSG.html_safe
      <div>
        Your export (#{@export.id}) containing #{@export.items.count}
        #{'item'.pluralize(@export.items.count)} is available for download at
        <a href="#{Rails.application.routes.url_helpers.export_download_path(@export)}">
          #{bag_name}.zip
        </a>
      </div>
    MSG
  end

  def failure_message
    <<~MSG.html_safe
      <div>
        Your export (#{@export.id}) failed with the following error:
        <pre>#{ERB::Util.html_escape(@export.message)}</pre>
      </div>
    MSG
  end
  # rubocop:enable Rails/OutputSafety
end
