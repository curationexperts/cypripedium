# frozen_string_literal: true
require 'rails_helper'

RSpec.describe VisibilityLabel do
  describe '.for' do
    it 'maps "open" visibility to "Public"' do
      expect(described_class.for('open')).to eq 'Public'
    end

    it 'maps "authenticated" visibility to "FRBM"' do
      expect(described_class.for('authenticated')).to eq 'FRBM'
    end

    it 'maps "restricted" visibility to "Private"' do
      expect(described_class.for('restricted')).to eq 'Private'
    end

    it 'returns nil for other values' do
      expect(described_class.for('a random string')).to be_nil
    end

    it 'accepts symbols' do
      expect(described_class.for(:restricted)).to eq 'Private'
    end
  end
end
