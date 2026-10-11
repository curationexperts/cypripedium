# frozen_string_literal: true

class ExportPackager
  class BagWriter
    def initialize(output_path)
      @bag = BagIt::Bag.new(output_path)
    end

    # Serialize the work's metadata to a JSON file in the metadata tag directory
    def write_item_metadata(work)
      @bag.add_tag_file("metadata/#{work.id}.json") do |io|
        io.write json(work)
      end
    end

    def write_content(path, file)
      @bag.add_file(path) do |io|
        io.set_encoding Encoding::BINARY
        io.write file.content
      end
    end

    # Writes accumulated metadata to a root-level tag file
    # Then generates final checksums for the bag
    # @param csv [String] CSV formatted data to be written
    def finalize(csv)
      @bag.add_tag_file(ExportPackager::METADATA_FILENAME) { |io| io.write csv }
      @bag.manifest!(algo: 'sha256')
    end

    private

    def json(work)
      ::ApplicationController.render(
        template: 'hyrax/base/show',
        formats: [:json],
        assigns: { curation_concern: work,
                   presenter: Hyrax::WorkShowPresenter.new(SolrDocument.new(work.to_solr), nil) }
      )
    end
  end
end
