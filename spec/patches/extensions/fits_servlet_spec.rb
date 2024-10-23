# frozen_string_literal: true
require 'rails_helper'

# Test class implementing the minimal interface for Hydra::FileCharacterization::Characterizer
class TestCharacterizer
  attr_accessor :filename, :tool_path
  def initialize(filename, tool_path = 'fits') # 'fits' is the #convention_based_tool_name in the Characterizer class
    @filename = filename
    @tool_path = tool_path
  end
end

describe Extensions::ServletCharacterizer do
  let(:test_class) { TestCharacterizer.include(described_class) }
  let(:characterizer) { test_class.new('pdf-sample.pdf') }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('FITS_SERVLET_URL').and_return(fits_servlet_url)
  end

  context 'with FITS servlet configured' do
    let(:fits_servlet_url) { 'http://localhost:8080/fits-1.2.0/' }

    it 'calls the http service' do
      expect(characterizer.send(:command)).to match(/curl .*pdf-sample.pdf .*examine/)
    end
  end

  context 'without the FITS servlet' do
    let(:fits_servlet_url) { nil }

    it 'calls fits via the shell' do
      expect(characterizer.send(:command)).to eq 'fits -i "pdf-sample.pdf"'
    end
  end

  describe Hydra::FileCharacterization::Characterizers::Fits do
    let(:characterizer) { described_class.new('pdf-sample.pdf') }
    let(:fits_servlet_url) { 'http://localhost:8080/fits-1.2.0/' }

    it 'calls the patched #command method' do
      expect(characterizer.send(:command)).to match(/curl .*pdf-sample.pdf .*examine/)
    end
  end
end
