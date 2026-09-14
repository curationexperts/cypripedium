# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreatorNames do
  let(:raw_names) { ['van Dijk, Herman K.', 'Smith, Bruce D. (Bruce David), 1954-2002 December 5', 'Cole, Harold Linh, 1957-2057'] }
  let(:creators) do
    raw_names.map { |name| FactoryBot.create(:creator, display_name: name) }
  end

  describe '.normalized_names' do
    it 'returns an empty array when given nil' do
      expect(described_class.normalized_names(nil)).to eq []
    end

    it 'returns an empty array when given an empty array' do
      expect(described_class.normalized_names([])).to eq []
    end

    it 'returns an array of normalized names' do
      ids = creators.map(&:id)
      expect(described_class.normalized_names(ids)).to eq ['Cole, Harold Linh', 'Smith, Bruce D.', 'van Dijk, Herman K.']
    end

    describe 'error handling' do
      # Documenting this behavior because it may not be expected.
      it 'omits invalid creators silently' do
        creators.last.destroy!
        expect(described_class.normalized_names(creators.map(&:id))).to eq ['Smith, Bruce D.', 'van Dijk, Herman K.']
      end

      it 'logs an error on invalid creators' do
        allow(Rails.logger).to receive(:error)
        creators.last.destroy!
        described_class.normalized_names(creators.map(&:id))
        expect(Rails.logger).to have_received(:error).with(/Invalid creator ID lookup/)
      end
    end
  end

  describe ".normalize" do
    it 'removes leading & trailing whitespace' do
      expect(described_class.normalize(" \tAvenancio-León, Carlos \n")).to eq 'Avenancio-León, Carlos'
    end

    it 'removes birth dates' do
      expect(described_class.normalize('Carlstrom, Charles T., 1960-')).to eq 'Carlstrom, Charles T.'
    end

    it 'removes death dates' do
      expect(described_class.normalize('Cole, Harold Linh, 1957-2057')).to eq 'Cole, Harold Linh'
    end

    it 'removes initial expansions' do
      expect(described_class.normalize('Juster, F. Thomas (Francis Thomas)')).to eq 'Juster, F. Thomas'
    end

    it 'returns only the normalized name' do
      expect(described_class.normalize('Smith, Bruce D. (Bruce David), 1954-2002 December 5')).to eq 'Smith, Bruce D.'
    end

    it 'returns an empty string for non-string values', :aggregate_failures do
      expect(described_class.normalize(nil)).to eq 'invalid_name'
      expect(described_class.normalize(123)).to eq 'invalid_name'
      expect(described_class.normalize(FactoryBot.build(:creator))).to eq 'invalid_name'
    end
  end
end
