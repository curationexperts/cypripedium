# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Export, type: :model do
  subject(:export) { described_class.new(user: user, format: :zip, items: ['abc123']) }

  let(:user) { create(:user) }

  describe 'associations' do
    it 'belongs to a user' do
      expect(export.user).to eq user
    end

    it 'has one attached export_file' do
      expect(export).to respond_to(:export_file)
    end
  end

  describe 'validations' do
    it 'requires a user, format, and at least one item' do
      expect(export).to be_valid
    end

    it 'is invalid without a user' do
      export.user = nil
      expect(export).not_to be_valid
      expect(export.errors[:user]).to be_present
    end

    it 'is invalid without a format' do
      export.format = nil
      expect(export).not_to be_valid
      expect(export.errors[:format]).to be_present
    end

    it 'is invalid without items' do
      export.items = []
      expect(export).not_to be_valid
      expect(export.errors[:items]).to be_present
    end
  end

  describe '#items' do
    it 'is an array' do
      expect(export.items).to be_an Array
    end

    it 'accepts an array of id strings' do
      export.items = ['abc123', 'def456']
      export.save!
      expect(export.reload.items).to eq ['abc123', 'def456']
    end
  end

  describe '#format' do
    it 'accepts :zip' do
      export.format = :zip
      expect(export).to be_valid
    end

    it 'accepts :bag' do
      export.format = :bag
      expect(export).to be_valid
    end

    it 'rejects unknown formats' do
      expect { export.format = :unknown_format }
        .to raise_error(ArgumentError)
    end
  end

  describe '#status' do
    it 'defaults to :unknown' do
      expect(export.status).to eq 'unknown'
    end

    it 'includes expected states' do
      expect(described_class.statuses.keys).to include('unknown', 'queued', 'working', 'failed', 'completed')
    end

    it 'rejects unknown statuses' do
      expect { export.status = :bogus }
        .to raise_error(ArgumentError)
    end
  end

  describe '#message' do
    it 'is nil by default' do
      expect(export.message).to be_nil
    end

    it 'persists a human-readable status description' do
      export.message = 'Export failed: source file not found'
      export.save!
      expect(export.reload.message).to eq 'Export failed: source file not found'
    end
  end

  describe 'system user' do
    it 'can be assigned User.system_user as the submitting user' do
      system_export = described_class.new(user: User.system_user, format: :zip, items: ['abc123'])
      expect(system_export).to be_valid
    end
  end
end
