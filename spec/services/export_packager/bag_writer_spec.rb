# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExportPackager::BagWriter do
  subject(:writer) { described_class.new(archive_root) }

  let(:tmp_dir) { Dir.mktmpdir }
  let(:archive_root) { File.join(tmp_dir, 'archive') }
  let(:file) { double('file', content: 'hello') }
  let(:work) { double('work', id: 'abc123', to_solr: { 'id' => 'abc123' }) }

  before { allow(ApplicationController).to receive(:render).and_return('{"id":"abc123"}') }

  after { FileUtils.remove_entry(tmp_dir) }

  describe '#write_item_metadata' do
    it "writes the work's JSON to metadata/<id>.json" do
      writer.write_item_metadata(work)
      expect(File.read(File.join(archive_root, 'metadata/abc123.json'))).to eq '{"id":"abc123"}'
    end

    it 'renders the work with the JSON show template' do
      writer.write_item_metadata(work)
      expect(ApplicationController).to have_received(:render).with(
        template: 'hyrax/base/show',
        formats: [:json],
        assigns: { curation_concern: work, presenter: an_instance_of(Hyrax::WorkShowPresenter) }
      )
    end
  end

  describe '#write_content' do
    it 'writes the content under data/' do
      writer.write_content('abc123/1/file.txt', file)
      expect(File.read(File.join(archive_root, 'data/abc123/1/file.txt'))).to eq 'hello'
    end

    it 'preserves binary content' do
      binary = "\xFF\xD8\xFF\xE0".b
      writer.write_content('abc123/image.jpg', double('file', content: binary))
      expect(File.binread(File.join(archive_root, 'data/abc123/image.jpg'))).to eq binary
    end
  end

  describe '#finalize' do
    let(:csv) { "internal_id,path\nabc123,abc123/1/file.txt\n" }

    before do
      writer.write_item_metadata(work)
      writer.write_content('abc123/1/file.txt', file)
      writer.finalize(csv)
    end

    it 'writes metadata.csv at the bag root' do
      expect(File.read(File.join(archive_root, 'metadata.csv'))).to eq csv
    end

    it 'writes a sha256 manifest listing each payload file' do
      expect(File.read(File.join(archive_root, 'manifest-sha256.txt')))
        .to eq "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824 data/abc123/1/file.txt\n"
    end

    it 'writes a sha1 manifest listing tag files' do
      expect(File.read(File.join(archive_root, 'tagmanifest-sha1.txt')).split("\n"))
        .to include(
              'd55c17704a33b9a6e63ae520319ad9c4c29ce4ed metadata.csv',
              'e5016c4d7b317bb5d585e1dcf898b6c0418660d2 metadata/abc123.json'
            )
    end

    it 'produces a valid bag' do
      bag = BagIt::Bag.new(archive_root)
      bag.valid?
      expect(bag.errors.full_messages).to eq []
    end
  end
end
