require 'rails_helper'

RSpec.describe BulkDownload do
  let(:publication) { FactoryBot.create(:publication) }
  let(:bulk_download) { described_class.new(publication.id) }
  let(:zip_hash) { '76cdb2bad9582d23c1f6f4d868218d6c' }

  describe 'getting a zip file' do
    it 'returns binary zip data' do
      allow_any_instance_of(described_class).to receive(:files).and_return([{ file_name: 'pdf_sample.pdf', content: file_fixture('pdf-sample.pdf').read }])
      expect(Digest::MD5.hexdigest(bulk_download.read_zip)).to eq('76cdb2bad9582d23c1f6f4d868218d6c')
    end
  end
end
