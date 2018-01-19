# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Contentdm::Record do
  let(:record) { described_class.new(first_record) }
  let(:doc) { File.open(file_fixture('ContentDM_XML_Full_Fields.xml')) { |f| Nokogiri::XML(f) } }
  let(:first_record) { doc.xpath("//record[1]") }

  context "when initialized with a Nokogiri document" do
    describe '#identifier' do
      it 'returns the idenitifer' do
        expect(record.identifier).to eq('19750900fedmwp22')
      end
    end
    describe '#title' do
      it 'returns a title with the author removed' do
        expect(record.title).to eq(['Classical macroeconomic model for the United States, a'])
      end
    end
    describe '#contributor' do
      it 'returns an array of contributors' do
        expect(record.contributor).to eq(['Federal Reserve Bank of Minneapolis. Research Dept.'])
      end
    end
    describe '#subject' do
      it 'returns an array of subject' do
        expect(record.subject).to eq(['Rational expectations (Economic theory)--United States.', 'Unemployment--United States--Statistical methods.'])
      end
    end

    describe '#description' do
      it 'returns an array of descriptions' do
        expect(record.description).to eq(['Natural unemployment rate ; Montarist model ; Postwar United States ; post-1945 ; Rational expectations theory', 'Description 2'])
      end
    end

    describe '#date_created' do
      it 'returns an array of created dates' do
        expect(record.date_created).to eq(['1975-09'])
      end
    end

    describe '#publisher' do
      it 'returns an array of publishers' do
        expect(record.publisher).to eq(['Minneapolis : Federal Reserve Bank of Minneapolis'])
      end
    end
    describe '#work_type' do
      it 'returns a work_type' do
        expect(record.work_type).to eq 'Publication'
      end
    end
  end
end
