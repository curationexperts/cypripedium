# frozen_string_literal: true
require 'rails_helper'
RSpec.describe Contentdm::Validator do
  let(:xml) { file_fixture('ContentDM_XML_Full_Fields.xml') }
  let(:invalid_xml) { file_fixture('cdm_xml_with_errors.xml') }
  let(:validator) { described_class.new(xml) }
  let(:validator_bad_xml) { described_class.new(invalid_xml) }

  context 'validating a valid export xml document' do
    it 'returns that the xml document has no errors' do
      expect(validator.result.empty?).to eq(true)
    end

    describe '#valid?' do
      it 'returns true' do
        expect(validator.valid?).to eq(true)
      end
    end

    describe '#validate' do
      it 'raises an exception' do
        expect { validator.validate }.not_to raise_error
      end
    end
  end

  context 'validating an invalid export  xml document' do
    it 'returns that the xml is not valid' do
      expect(validator_bad_xml.result.empty?).to eq(false)
    end

    describe '#valid?' do
      it 'returns false' do
        expect(validator_bad_xml.valid?).to eq(false)
      end
    end

    describe '#validate' do
      it 'raises an exception' do
        expect { validator_bad_xml.validate }.to raise_error('XML is invalid')
      end
    end
  end
end
