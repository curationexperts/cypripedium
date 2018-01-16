require 'rails_helper'

RSpec.describe ContentdmRecord do
  let(:record) { described_class.new(first_record) }
  let(:doc) { File.open(file_fixture('ContentDM_XML_Full_Fields.xml')) { |f| Nokogiri::XML(f) } }
  let(:first_record) { doc.xpath("//record[1]") }

  context "when initialized with a Nokogiri document" do
    it 'returns the idenitifer' do
      expect(record.identifer).to eq('19750900fedmwp22')
    end

    it 'returns a title with the author removed' do
      expect(record.title).to eq(['Classical macroeconomic model for the United States, a'])
    end

    it 'returns an array of creators' do
      expect(record.creators).to eq(["Sargent, Thomas J."])
    end
  end
end
