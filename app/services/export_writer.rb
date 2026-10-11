# frozen_string_literal: true
require 'csv'

class ExportWriter
  METADATA_HEADERS = [:internal_id, :member_id, :type, :visibility, :representative_id, :title,
                      :creator, :corporate_author, :date_created, :date_uploaded, :date_modified,
                      :location_url, :identifier, :filename, :path, :series, :issue_number, :collection,
                      :abstract, :table_of_contents].freeze

  SUPPORTED_TYPES = [Publication, Dataset, ConferenceProceeding].freeze

  VISIBILITY_FILTER = {
    'open' => ['open'].freeze,
    'authenticated' => ['open', 'authenticated'].freeze,
    'restricted' => ['open', 'authenticated', 'restricted'].freeze
  }.freeze

  def self.package_itmes(export)
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
      @bag = BagIt::Bag.new(File.join(tmp_dir, bag_name))
      build_bag
      zip_path = compress(tmp_dir)
      attach(zip_path)
    end
    @item_count
  end

  private

  def bag_name
    @export.base_filename
  end

  def permitted_visibilities
    @visibility ||= VISIBILITY_FILTER[@export.visibility]
  end

  def build_bag
    @export.items.each do |item_id|
      work = ActiveFedora::Base.find(item_id)
      add_item_to_bag(work)
    end
    write_metadata_csv
    @bag.manifest!(algo: 'sha256')
  end

  def write_metadata_csv
    @bag.add_tag_file('metadata.csv') do |io|
      csv = CSV.new(io, headers: METADATA_HEADERS, write_headers: true)
      @metadata_rows.each { |row| csv << row }
    end
  end

  def add_item_to_bag(work)
    raise "Unsupported work type: #{work.class}" unless SUPPORTED_TYPES.include?(work.class)
    return unless permitted_visibilities.include?(work.visibility)
    add_metadata_for_item(work)
    add_members_to_bag(work)
    @metadata_rows << []
    @item_count += 1
  end

  def add_metadata_for_item(work)
    add_metadata_row(
      internal_id: work.id,
      type: work.class.to_s,
      visibility: VisibilityLabel.for(work.visibility),
      representative_id: work.representative_id,
      title: work.title.join('|'),
      creator: normalized_creators(work),
      corporate_author: work.corporate_name&.join('|'),
      date_created: work.date_created.join('|'),
      date_uploaded: work.date_uploaded&.strftime('%F'),
      date_modified: work.date_modified&.strftime('%F'),
      location_url: Rails.application.routes.url_helpers.polymorphic_url(work, host: Rails.application.config.rdf_uri),
      identifier: work.identifier.join('|'),
      series: work.series.join('|'),
      issue_number: work.issue_number.join('|'),
      collection: work.member_of_collections.to_a.join('|'),
      abstract: work.abstract.join('|'),
      table_of_contents: work.table_of_contents.join('|')
    )
  end

  def add_metadata_for_file(work_id, file_set, path)
    add_metadata_row(
      internal_id: work_id,
      member_id: file_set.id,
      type: 'File',
      visibility: VisibilityLabel.for(file_set.visibility),
      date_uploaded: file_set.date_uploaded&.strftime('%F'),
      location_url: Hyrax::Engine.routes.url_helpers.download_url(file_set, host: Rails.application.config.rdf_uri),
      filename: file_set.original_file.file_name.first,
      path: "data/#{path}"
    )
  end

  def add_metadata_row(row)
    row.assert_valid_keys(*METADATA_HEADERS)
    @metadata_rows << row
  end

  def normalized_creators(work)
    creators = CreatorNames.normalized_names(work.creator_id)
    creators.join('|')
  end

  def add_members_to_bag(work)
    # serialize the work's metadata to a JSON file in the metadata tag directory
    @bag.add_tag_file("metadata/#{work.id}.json") do |io|
      json = ::ApplicationController.render(
        template: 'hyrax/base/show',
        formats: [:json],
        assigns: { curation_concern: work, presenter: Hyrax::WorkShowPresenter.new(SolrDocument.new(work.to_solr), nil) }
      )
      io.write json
    end

    # add the work's files to the bag
    file_sets = visible_file_sets(work)
    padding = file_sets.count.to_s.length

    file_sets.each.with_index(1) do |file_set, index|
      file = file_set.original_file
      next if file.file_name.first.empty?
      path = "#{work.id}/#{index.to_s.rjust(padding, '0')}/#{file.file_name.first}"
      @bag.add_file(path) do |io|
        io.set_encoding Encoding::BINARY
        io.write file.content
      end
      add_metadata_for_file(work.id, file_set, path)
    end
  end

  def visible_file_sets(work)
    work.ordered_members.to_a.select { |member| member.file_set? && permitted_visibilities.include?(member.visibility) }
  end

  def compress(tmp_dir)
    zip_path = File.join(tmp_dir, "#{bag_name}.zip")
    bag_dir  = @bag.bag_dir
    Zip::File.add_recursive(zip_path, bag_dir, prefix: @export.base_filename)

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
end
