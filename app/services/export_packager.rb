# frozen_string_literal: true
require 'csv'

# Generates a compressed archive of metadata and files
# from an Export's item IDs and attaches it to the Export.
class ExportPackager
  METADATA_HEADERS = [:internal_id, :member_id, :type, :visibility, :representative_id, :title,
                      :creator, :corporate_author, :date_created, :date_uploaded, :date_modified,
                      :location_url, :identifier, :filename, :path, :series, :issue_number, :collection,
                      :abstract, :table_of_contents].freeze

  METADATA_FILENAME = 'metadata.csv'

  SUPPORTED_TYPES = [Publication, Dataset, ConferenceProceeding].freeze

  VISIBILITY_FILTER = {
    'open' => ['open'].freeze,
    'authenticated' => ['open', 'authenticated'].freeze,
    'restricted' => ['open', 'authenticated', 'restricted'].freeze
  }.freeze

  def self.package_items(export)
    new(export).run
  end

  def initialize(export)
    @export        = export
    @metadata_rows = []
    @item_count    = 0
  end

  # @return [Integer] number of works included after visibility filtering
  def run
    Dir.mktmpdir do |tmp_dir|
      @tmp_dir = tmp_dir
      build_archive
      finalize_archive
      attach_archive
    end
    @item_count
  end

  private

  def archive_root
    @archive_root = File.join(@tmp_dir, 'archive')
  end

  def writer
    @writer ||= case @export.format
                when 'zip' then ExportPackager::ZipWriter.new(archive_root)
                when 'bag' then ExportPackager::BagWriter.new(archive_root)
                end
  end

  def permitted_visibilities
    VISIBILITY_FILTER[@export.visibility]
  end

  def build_archive
    @export.items.each do |item_id|
      add_item(item_id)
    end
  end

  def finalize_archive
    writer.finalize(metadata_csv)
  end

  def metadata_csv
    CSV.generate(headers: METADATA_HEADERS, write_headers: true) do |csv|
      @metadata_rows.each { |row| csv << row }
    end
  end

  def add_item(item_id)
    work = ActiveFedora::Base.find(item_id)
    raise "Unsupported work type: #{work.class}" unless SUPPORTED_TYPES.include?(work.class)
    return unless permitted_visibilities.include?(work.visibility)
    add_metadata_for_item(work)
    add_members(work)
    @metadata_rows << []
    @item_count += 1
  end

  def add_metadata_for_item(work)
    writer.write_item_metadata(work)
    # rubocop:disable Layout/HashAlignment
    add_metadata_row(
      internal_id:        work.id,
      type:               work.class.to_s,
      visibility:         VisibilityLabel.for(work.visibility),
      representative_id:  work.representative_id,
      title:              work.title.join('|'),
      creator:            normalized_creators(work),
      corporate_author:   work.corporate_name&.join('|'),
      date_created:       work.date_created.join('|'),
      date_uploaded:      work.date_uploaded&.strftime('%F'),
      date_modified:      work.date_modified&.strftime('%F'),
      location_url:       Rails.application.routes.url_helpers.polymorphic_url(work, host: Rails.application.config.rdf_uri),
      identifier:         work.identifier.join('|'),
      series:             work.series.join('|'),
      issue_number:       work.issue_number.join('|'),
      collection:         work.member_of_collections.to_a.join('|'),
      abstract:           work.abstract.join('|'),
      table_of_contents:  work.table_of_contents.join('|')
    )
    # rubocop:enable Layout/HashAlignment
  end

  def add_metadata_for_file(work_id, file_set, path)
    # rubocop:disable Layout/HashAlignment
    add_metadata_row(
      internal_id:        work_id,
      member_id:          file_set.id,
      type:               'File',
      visibility:         VisibilityLabel.for(file_set.visibility),
      title:              file_set.title.join('|'),
      date_uploaded:      file_set.date_uploaded&.strftime('%F'),
      location_url:       Hyrax::Engine.routes.url_helpers.download_url(file_set, host: Rails.application.config.rdf_uri),
      filename:           file_set.original_file.file_name.first,
      path:               path
    )
    # rubocop:enable Layout/HashAlignment
  end

  def add_metadata_row(row)
    row.assert_valid_keys(*METADATA_HEADERS)
    @metadata_rows << row
  end

  def normalized_creators(work)
    creators = CreatorNames.normalized_names(work.creator_id)
    creators.join('|')
  end

  def add_members(work)
    # add the work's files to package
    file_sets = visible_file_sets(work)
    count = file_sets.count

    file_sets.each.with_index(1) do |file_set, index|
      file = file_set.original_file
      relative_path = File.join(work.id, padded_index(index, count), file.file_name.first)
      writer.write_content(relative_path, file)
      add_metadata_for_file(work.id, file_set, relative_path)
    end
  end

  def visible_file_sets(work)
    work.ordered_members.to_a.select { |member| member.file_set? && permitted_visibilities.include?(member.visibility) }
  end

  def padded_index(index, count)
    return '' if count == 1
    index.to_s.rjust(count.to_s.length, '0')
  end

  def attach_archive
    output_file = File.join(@tmp_dir, "export.zip")
    Zip::File.add_recursive(output_file, archive_root, prefix: @export.base_filename)
    File.open(output_file) do |file|
      @export.export_file.attach(io: file, filename: "#{@export.base_filename}.zip", content_type: 'application/zip')
    end
  end
end
