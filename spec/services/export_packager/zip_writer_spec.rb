# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExportPackager::ZipWriter do
  subject(:writer) { described_class.new(archive_root) }

  let(:tmp_dir) { Dir.mktmpdir }
  let(:archive_root) { File.join(tmp_dir, 'archive') }
  let(:file) { double('file', content: 'hello') }
  let(:work) { double('work') }

  after { FileUtils.remove_entry(tmp_dir) }

  describe '#initialize' do
    it 'creates the archive root', :aggregate_failures do
      expect(Dir.exist?(archive_root)).to be false
      described_class.new(archive_root)
      expect(Dir.exist?(archive_root)).to be true
    end
  end

  describe '#write_item_metadata' do
    it "is a no-op and does not write anything" do
      writer.write_item_metadata(work)
      expect(Dir.children(archive_root)).to eq []
    end
  end

  describe '#write_content' do
    it 'writes the content under the archive root' do
      writer.write_content('abc123/1/file.txt', file)
      expect(File.read(File.join(archive_root, 'abc123/1/file.txt'))).to eq 'hello'
    end

    it 'preserves binary content' do
      binary = "\xFF\xD8\xFF\xE0".b
      writer.write_content('abc123/image.jpg', double('file', content: binary))
      expect(File.binread(File.join(archive_root, 'abc123/image.jpg'))).to eq binary
    end
  end

  describe '#finalize' do
    let(:csv) { "internal_id,path\nabc123,abc123/1/file.txt\n" }

    it 'writes metadata.csv at the archive root' do
      writer.finalize(csv)
      expect(File.read(File.join(archive_root, 'metadata.csv'))).to eq csv
    end

    it 'only adds metadata.csv' do
      writer.write_content('abc123/1/file.txt', file)
      writer.finalize(csv)
      expect(Dir.glob('**/*', base: archive_root))
        .to contain_exactly('abc123', 'abc123/1', 'abc123/1/file.txt', 'metadata.csv')
    end
  end
end
