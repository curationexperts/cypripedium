# frozen_string_literal: true

require 'rails_helper'

# Exercises the parts of ExportPackager that the fast ExportPackager suite stubs:
# stored visibility, ordered_members, original_file, URL generation on saved records, and BagWriter JSON.
RSpec.describe ExportPackager do
  include_context 'export helpers'

  before(:all) do
    public_file  = FactoryBot.create(:file_set, id: 'public_file', content: File.open(file_fixture('pdf-sample.pdf')), visibility: 'open')
    private_file = FactoryBot.create(:file_set, id: 'private_file', content: File.open(file_fixture('tiny.txt')), visibility: 'restricted')

    FactoryBot.create(:publication, id: 'public_work', title: ['Public Publication'], visibility: 'open', file_sets: [public_file, private_file])
    FactoryBot.create(:publication, id: 'private_work', title: ['Private Publication'], visibility: 'restricted')
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
    ActiveFedora::Cleaner.clean!
  end

  describe '.package_items' do
    context 'for an open bag export' do
      let(:export) do
        FactoryBot.create(:export, format: :bag, visibility: 'open',
                                   items: ['public_work', 'private_work'], filename: 'test_export')
      end

      it 'includes only open works and files', :aggregate_failures do
        expect(described_class.package_items(export)).to eq 1

        expect(zip_filenames(export))
          .to contain_exactly(
             'test_export/bagit.txt',
             'test_export/bag-info.txt',
             'test_export/manifest-sha256.txt',
             'test_export/tagmanifest-md5.txt',
             'test_export/tagmanifest-sha1.txt',
             'test_export/metadata.csv',
             'test_export/metadata/public_work.json',
             'test_export/data/public_work/pdf-sample.pdf'
           )
        csv = parsed_csv(export)
        expect(csv.size).to eq 2
        expect(csv[0].to_h)
          .to include(
             'internal_id' => 'public_work',
             'member_id' => nil,
             'type' => 'Publication',
             'visibility' => 'Public',
             'location_url' => 'http://localhost:3000/concern/publications/public_work'
             # 'error' => nil
           )
        expect(csv[1].to_h)
          .to include(
             'internal_id' => 'public_work',
             'member_id' => 'public_file',
             'type' => 'File',
             'visibility' => 'Public',
             'location_url' => 'http://localhost:3000/downloads/public_file',
             'filename' => 'pdf-sample.pdf',
             'path' => 'public_work/pdf-sample.pdf'
             # 'error' => nil
           )
      end
    end

    context 'for a restricted zip export' do
      let(:export) do
        FactoryBot.create(:export, format: :zip, visibility: 'restricted',
                                   items: ['public_work', 'private_work'], filename: 'test_export')
      end

      it 'includes every work and file', :aggregate_failures do
        expect(described_class.package_items(export)).to eq 2

        expect(zip_filenames(export)).to eq [
          'test_export/metadata.csv',
          'test_export/public_work/1/pdf-sample.pdf',
          'test_export/public_work/2/tiny.txt'
        ]

        # Works are listed in id order, so private_work comes first
        # rubocop:disable Layout
        rows = parsed_csv(export).map { |row|
                row.values_at('internal_id', 'member_id',    'type',     'visibility', 'path',                      'error') }
        expect(rows).to eq [ ["private_work", nil,           "Publication", "Private",  nil,                           nil],
                             ["public_work",  nil,           "Publication", "Public",   nil,                           nil],
                             ["public_work", "public_file",  "File",        "Public",  "public_work/1/pdf-sample.pdf", nil],
                             ["public_work", "private_file", "File",        "Private", "public_work/2/tiny.txt",       nil] ]
        # rubocop:enable Layout
      end
    end
  end
end
