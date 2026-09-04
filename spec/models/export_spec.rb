# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Export, type: :model do
  subject(:export) { described_class.new(user: user, items: ['abc123']) }

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

    it 'limits filename length to 250 characters' do
      export.filename = 'a' * 251
      expect(export).not_to be_valid
      expect(export.errors.where(:filename, :too_long)).to be_present
    end

    it 'requires filename to start with a letter' do
      export.filename = '(Invalid first character)'
      expect(export).not_to be_valid
      expect(export.errors.where(:filename, :invalid)).to be_present
    end

    it 'restricts filename to valid characters' do
      export.filename = 'This ⛔️ is not valid'
      expect(export).not_to be_valid
      expect(export.errors.where(:filename, :invalid)).to be_present
      expect(export.errors.messages[:filename].join(' ')).to include('must use only')
    end
  end

  describe '#items' do
    it 'is an array' do
      expect(export.items).to be_an Array
    end

    it 'sorts and deduplicates on assignment' do
      export = build(:export, items: ['zzz', 'aaa', 'abc', 'aaa'])
      expect(export.items).to eq ['aaa', 'abc', 'zzz']
    end

    it 'removes blank items' do
      export = build(:export, items: ['789', nil, '123', 'atoz', '', 'abc'])
      expect(export.items).to eq ['123', '789', 'abc', 'atoz']
    end

    it 'persists as a sorted and deduplicated list' do
      export = create(:export, items: ['zzz', 'aaa', 'abc', 'aaa'])
      expect(export.reload.items).to eq ['aaa', 'abc', 'zzz']
    end
  end

  describe '#filename' do
    it 'normalizes blank fielnames' do
      export.filename = '    '
      expect(export.filename).to eq nil
    end
  end

  describe '#format' do
    it 'defaults to "bag"' do
      expect(export.format).to eq 'bag'
    end

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

  describe '#visibility' do
    it 'defaults to :open' do
      expect(export.visibility).to eq 'open'
    end

    it 'mirrors Hyrax visibility' do
      # See Hyrax.config.visibility_map.visibilities
      expect(described_class.visibilities.keys).to eq(['open', 'authenticated', 'restricted'])
    end

    it 'rejects invalid visibilities' do
      expect { export.visibility = :bogus }
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

  describe '#base_filename' do
    it 'returns the filename when it is present' do
      export.filename = 'my_export'
      expect(export.base_filename).to eq 'my_export'
    end

    it 'returns the default_filename when filename is blank' do
      export.filename = nil
      expect(export.base_filename).to eq export.default_filename
    end
  end

  describe '#default_filename' do
    let(:export) { build(:export, format: :bag, items: ['abc123']) }

    it 'includes segments in the expected order' do
      prefix = Rails.application.config.bag_prefix
      expect(export.default_filename).to eq prefix + '_bag_abc123'
    end

    context 'disambiguation' do
      def attach_file(export)
        export.export_file.attach(
          io: Rails.root.join('spec', 'fixtures', 'files', 'test_file.zip').open,
          filename: "#{export.default_filename}.zip",
          content_type: 'application/zip'
        )
      end

      it 'omits the counter when no prior export has the same base name' do
        expect(export.default_filename).to end_with 'bag_abc123'
      end

      it 'adds a counter for each additional export with the same base name' do
        2.times do
          prior = create(:export, format: :bag, items: ['abc123'])
          attach_file(prior)
        end
        expect(export.default_filename).to end_with 'bag_abc123_3'
      end
    end
  end

  describe '#duplicates?' do
    it 'returns true if there are exports with the same items' do
      create(:export, items: ['abc123'])
      expect(described_class.new(items: ['abc123']).duplicates?).to be true
    end

    it 'returns false if there are no matching exports' do
      expect(subject.duplicates?).to be false
    end
  end

  describe '#duplicate_records' do
    it 'returns a list of exports with the same items' do
      create(:export, items: ['abc123'])
      expect(described_class.new(items: ['abc123']).duplicate_records).to eq [described_class.last]
    end

    it 'returns an empty array if there are no matching exports' do
      expect(subject.duplicate_records).to be_empty
    end
  end

  describe 'system user' do
    it 'can be assigned User.system_user as the submitting user' do
      system_export = described_class.new(user: User.system_user, format: :zip, items: ['abc123'])
      expect(system_export).to be_valid
    end
  end
end
