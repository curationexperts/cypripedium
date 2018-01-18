require 'rails_helper'

describe Contentdm::ImportFile do
  let(:doc) { File.open(file_fixture('ContentDM_XML_Full_Fields.xml')) { |f| Nokogiri::XML(f) } }
  let(:first_record) { doc.xpath("//record[1]") }
  let(:record) { Contentdm::Record.new(first_record) }
  let(:collection_path) { Rails.root.join('spec', 'fixtures', 'files', 'Sargent_and_Sims') }
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'files', 'Sargent_and_Sims', '19750900fedmwp22.pdf').to_s }
  let(:bad_file_path) { Rails.root.join('data', 'Sargent_and_Sims', 'bad_file_path.pdf') }
  let(:extension) { '.pdf' }
  let(:user) { ::User.batch_user }
  let(:import_file) { described_class.new(record, collection_path, user) }

  context 'when given the details for creating a new File to import' do
    describe '#uploaded_file' do
      it 'returns a Hyrax::UploadedFile' do
        expect(import_file.uploaded_file.is_a?(Hyrax::UploadedFile)).to eq(true)
      end
    end
    describe '#file_path' do
      it 'returns the file path' do
        expect(import_file.file_path.to_s).to eq(file_path)
      end
    end

    describe '#extension' do
      it 'returns the extension' do
        expect(import_file.extension).to eq(extension)
      end
    end

    describe '#check_for_file' do
      it 'checks to see if a file exists at a path and returns true if it exists' do
        expect(import_file.check_for_file(file_path)).to eq(true)
      end
      it 'checks to see if a file exists at a path and returns false if it does not exist' do
        expect(import_file.check_for_file(bad_file_path)).to eq(false)
      end
    end
  end
end
