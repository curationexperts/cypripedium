# frozen_string_literal: true
require 'rails_helper'

describe RDF::Markdown::Literal do
  let(:literal) { described_class.new(value) }
  let(:literal_id) { literal.id }
  let(:literal_value) { literal.value }
  let(:value) { 'test' }
  let(:datatype) { described_class.new(value).datatype.to_s }
  let(:markdown_datatype) { "http://ns.ontowiki.net/SysOnt/Markdown" }

  describe '#id' do
    it 'returns the value as id' do
      expect(literal_id).to eq(value)
    end
  end

  describe '#find' do
    it 'returns the literal when searching by the value' do
      expect(literal_value).to eq(value)
    end
  end

  describe '#datatype' do
    it 'returns a markdown datatype' do
      expect(datatype).to eq(markdown_datatype)
    end
  end
end
