require 'rails_helper'
require 'nokogiri'

RSpec.describe RdfXmlService, type: :model do
  subject(:rdf_xml_service) { described_class.new(work_id: publication.id) }

  let(:pdf_file) do
    File.open(file_fixture('pdf-sample.pdf')) { |file| create(:file_set, content: file) }
  end

  let(:image_file) do
    File.open(file_fixture('sir_mordred.jpg')) { |file| create(:file_set, content: file) }
  end

  let(:publication) do
    create(:publication, title: ['My Publication'], file_sets: [pdf_file, image_file])
  end

  describe '#xml' do
    it 'returns a valid rdf+xml version of the metadata for a publication' do
      doc = Nokogiri::XML(rdf_xml_service.xml)
      expect(doc.errors).to eq([])
      expect(doc.to_s).to match(/My Publication/)
    end
  end
end
