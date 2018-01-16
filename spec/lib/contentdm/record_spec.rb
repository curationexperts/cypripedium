require 'rails_helper'

RSpec.describe Contentdm::Record do
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

    it 'returns an array of contributors' do
      expect(record.contributors).to eq(['Federal Reserve Bank of Minneapolis. Research Dept.'])
    end

    it 'returns an array of subject' do
      expect(record.subjects).to eq(['Rational expectations (Economic theory)--United States.', 'Unemployment--United States--Statistical methods.'])
    end

    it 'returns an array of descriptions' do
      expect(record.descriptions).to eq(['Natural unemployment rate ; Montarist model ; Postwar United States ; post-1945 ; Rational expectations theory'])
    end

    it 'returns an array of created dates' do
      expect(record.date_created).to eq(['1975-09'])
    end

    it 'returns an array of publishers' do
      expect(record.publishers).to eq(['Minneapolis : Federal Reserve Bank of Minneapolis'])
    end
  end
end
