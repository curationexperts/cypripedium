# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExportPackager do
  include_context 'export helpers'

  let(:publication) { @publication }
  let(:restricted_publication) { @publication2 }
  let(:file_set) { @pdf }
  let(:restricted_publication_open_file_set) { @pdf_alt }

  # We override the default export format to zip, because we don't need the bag format overhead in most tests.
  # We keep most tests fast by using a restricted work on an open export, so nothing passes the visibility filter.
  let(:export) { FactoryBot.create(:export, format: :zip, items: [restricted_publication.id], filename: 'test_export') }

  before(:all) do
    pdf_path = Rails.root.join('spec', 'fixtures', 'files', 'pdf-sample.pdf')
    @pdf     = FactoryBot.create(:file_set, content: File.open(pdf_path), visibility: 'open', date_uploaded: Time.zone.parse('2020-07-31'))
    @pdf_dup = FactoryBot.create(:file_set, content: File.open(pdf_path), visibility: 'restricted')
    @pdf_alt = FactoryBot.create(:file_set, content: File.open(pdf_path), visibility: 'open', date_uploaded: Time.zone.parse('1999-10-27'))
    @txt     = FactoryBot.create(:file_set, content: File.open(Rails.root.join('spec', 'fixtures', 'files', 'tiny.txt')), visibility: 'authenticated')

    creator = FactoryBot.create(:creator, display_name: 'Smith, Jane')
    additional_creator = FactoryBot.create(:creator, display_name: 'Gordon, Robert J. (Robert James), 1940-')

    upload_time = Time.zone.parse('2019-04-11')
    modification_time = Time.zone.parse('2020-01-15T14:34:27Z')

    @publication =
      FactoryBot.create(:publication,
                        title: ['Test Publication'],
                        creator_id: [creator.id, additional_creator.id],
                        corporate_name: ['Federal Reserve Bank of Minneapolis'],
                        date_created: ['2020-01-15'],
                        date_uploaded: upload_time,
                        date_modified: modification_time,
                        abstract: ['A test abstract'],
                        identifier: ['https://doi.org/10.21034/sr.999'],
                        table_of_contents: ['Chapter 1; Chapter 2'],
                        series: ['Series 1', 'Series 2'],
                        issue_number: ['Vol. 44, No. 4'],
                        file_sets: [@pdf, @pdf_dup, @txt],
                        representative_id: @pdf.id,
                        visibility: 'open')

    @publication2 =
      FactoryBot.create(:publication,
                        title: ['Restricted Publication'],
                        creator: ['Other, A.N.', 'Nescio, Nomen'],
                        corporate_name: ['Federal Reserve Bank of Minneapolis'],
                        date_created: ['2020-01-10'],
                        date_modified: modification_time,
                        abstract: ['A test abstract'],
                        identifier: ['https://doi.org/10.21034/sr.888'],
                        table_of_contents: ['Introduction, One, Two, Appendix'],
                        file_sets: [@pdf_alt],
                        representative_id: @pdf_alt.id,
                        visibility: 'restricted')
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
    ActiveFedora::Cleaner.clean!
  end

  describe '#run' do
    it 'raises an exception on unsupported work types' do
      allow(ActiveFedora::Base).to receive(:find).and_return(Collection.new)

      expect { described_class.new(export).run }
        .to raise_error(RuntimeError, 'Unsupported work type: Collection')
    end
  end

  describe 'export_file' do
    it 'is attached to the export on success' do
      described_class.package_items(export)
      expect(export.reload.export_file).to be_attached
    end

    it 'is not attached to the export on exception' do
      allow(ActiveFedora::Base).to receive(:find).and_raise(ActiveFedora::ObjectNotFoundError)

      expect { described_class.package_items(export) }.to raise_error(ActiveFedora::ObjectNotFoundError)
      expect(export.reload.export_file).not_to be_attached
    end

    describe 'filename' do
      context 'with no override' do
        let(:export) { FactoryBot.create(:export, format: :zip, items: [restricted_publication.id]) }
        it 'has the expected default', :aggregate_failures do
          described_class.package_items(export)
          expect(export.export_file.filename.base).to eq export.default_filename
          expect(export.export_file.filename.extension).to eq 'zip'
        end
      end

      context 'when overridden' do
        let(:export) { FactoryBot.create(:export, format: :zip, items: [restricted_publication.id], filename: 'my_export') }
        it 'uses the user supplied value' do
          described_class.package_items(export)
          expect(export.export_file.filename).to eq 'my_export.zip'
        end
      end
    end
  end

  describe '#metadata_csv' do
    let(:work)   { FactoryBot.build(:publication, id: 'abc123', visibility: 'open', file_sets: []) }
    let(:export) { FactoryBot.create(:export, format: :zip, items: ['abc123'], filename: 'test_export') }

    before { allow(ActiveFedora::Base).to receive(:find).with('abc123').and_return(work) }

    it 'includes works with no files attached' do
      described_class.package_items(export)
      expect(parsed_csv(export)['internal_id']).to eq ['abc123']
    end

    # Test for the order of specific columns, not intended to be comprehensive
    it 'orders key header columns' do
      described_class.package_items(export)
      headers = parsed_csv(export).headers
      expect(headers.first(4)).to eq ['internal_id', 'member_id', 'type', 'visibility']
      expect(headers.last(2)).to eq ['abstract', 'table_of_contents'] # potentially long strings should go to the end
    end
  end

  describe 'temporary file cleanup' do
    let(:packager) { described_class.new(export) }
    let(:tmp_dir)  { packager.instance_variable_get(:@tmp_dir) }

    it 'removes the temporary directory after success' do
      packager.run
      expect(Dir.exist?(tmp_dir)).to be false
    end

    it 'removes the temporary directory after failure' do
      allow(ActiveFedora::Base).to receive(:find).and_raise(ActiveFedora::ObjectNotFoundError)

      expect { packager.run }.to raise_error(ActiveFedora::ObjectNotFoundError)
      expect(Dir.exist?(tmp_dir)).to be false
    end
  end

  describe 'visibility filtering' do
    let(:export) { FactoryBot.create(:export, format: :zip, items: [publication.id, restricted_publication.id], filename: 'test_export') }

    it 'only includes "open" files in "open" exports', :aggregate_failures do
      # Because this is the shortest export, we change the format to :bag to ensure we're testing end-to-end
      # BagIt export functionality with real fedora objects. The BagWriter tests generally use mocks.
      export.update!(format: :bag, visibility: 'open')

      item_count = described_class.package_items(export)
      expect(item_count).to eq 1

      # payload checks
      zip_names = zip_filenames(export).map { |path| path.delete_prefix("test_export/") }
      expect(zip_names).to contain_exactly(
                             'bagit.txt',
                             'bag-info.txt',
                             'manifest-sha256.txt',
                             'tagmanifest-md5.txt',
                             'tagmanifest-sha1.txt',
                             'metadata.csv',
                             "metadata/#{publication.id}.json",
                             "data/#{publication.id}/pdf-sample.pdf"
                           )

      # metadata checks
      csv = parsed_csv(export)
      expect(csv.length).to eq 2 # work + fileset
      expect(csv[0].to_hash)
        .to include({
                      'internal_id' => publication.id,
                      'member_id' => nil,
                      'type' => 'Publication',
                      'title' => 'Test Publication',
                      'corporate_author' => 'Federal Reserve Bank of Minneapolis',
                      'creator' => 'Gordon, Robert J.|Smith, Jane',
                      'date_created' => '2020-01-15',
                      'date_modified' => '2020-01-15',
                      'date_uploaded' => '2019-04-11',
                      'abstract' => 'A test abstract',
                      'location_url' => "http://localhost:3000/concern/publications/#{publication.id}",
                      'identifier' => 'https://doi.org/10.21034/sr.999',
                      'table_of_contents' => 'Chapter 1; Chapter 2',
                      'series' => a_string_matching(/Series 1/), # Hyrax doesn't guarantee order of series
                      'issue_number' => 'Vol. 44, No. 4',
                      'collection' => '',
                      'visibility' => 'Public',
                      'representative_id' => file_set.id,
                      'filename' => nil,
                      'path' => nil
                    })
      expect(csv[1].to_hash)
        .to include({
                      'internal_id' => publication.id,
                      'member_id' => file_set.id,
                      'type' => 'File',
                      'visibility' => 'Public',
                      'title' => nil,
                      'filename' => 'pdf-sample.pdf',
                      'path' => "#{publication.id}/pdf-sample.pdf",
                      'date_uploaded' => '2020-07-31',
                      'location_url' => "http://localhost:3000/downloads/#{file_set.id}",
                      'representative_id' => nil,
                      'identifier' => nil,
                      'table_of_contents' => nil,
                      'abstract' => nil,
                      'series' => nil,
                      'issue_number' => nil,
                      'collection' => nil
                    })
    end

    it 'omits "restricted" files from "authenticated" exports', :aggregate_failures do
      export.update!(visibility: 'authenticated')
      described_class.package_items(export)
      zip_names = zip_filenames(export)
      expect(zip_names).to contain_exactly(
                              "test_export/metadata.csv",
                              "test_export/#{publication.id}/1/pdf-sample.pdf",
                              "test_export/#{publication.id}/2/tiny.txt"
                              # does not include the restricted fileset
                            )
    end

    it 'includes all files in "restricted" exports', :aggregate_failures do
      export.update!(visibility: 'restricted')
      described_class.package_items(export)
      zip_names = zip_filenames(export)

      # structure checks
      expect(zip_names).to contain_exactly(
                             "test_export/metadata.csv",
                              "test_export/#{publication.id}/1/pdf-sample.pdf",
                              "test_export/#{publication.id}/2/pdf-sample.pdf",
                              "test_export/#{publication.id}/3/tiny.txt",
                              "test_export/#{restricted_publication.id}/pdf-sample.pdf"
                            )

      # metadata checks
      csv = parsed_csv(export)
      expect(csv.length).to eq 6 # public work + fileset x3 + restricted work + fileset

      # Work rows are ordered by ID (randomly assigned NOID), so we can't rely on the overall order of the CSV rows,
      # But the metadata and fileset order within a work are predictable
      restricted_pub_metadata = csv.select { |r| r['internal_id'] == restricted_publication.id }
      expect(restricted_pub_metadata[0].to_hash)
        .to include({
                      'internal_id' => restricted_publication.id,
                      'member_id' => nil,
                      'type' => 'Publication',
                      'title' => 'Restricted Publication',
                      'corporate_author' => 'Federal Reserve Bank of Minneapolis',
                      'creator' => '', # we don't support string creator names
                      'date_created' => '2020-01-10',
                      'date_uploaded' => nil, # shouldn't happen in real life, but testing here for robustness
                      'date_modified' => '2020-01-15',
                      'abstract' => 'A test abstract',
                      'location_url' => "http://localhost:3000/concern/publications/#{restricted_publication.id}",
                      'identifier' => 'https://doi.org/10.21034/sr.888',
                      'table_of_contents' => 'Introduction, One, Two, Appendix',
                      'series' => '',
                      'issue_number' => '',
                      'collection' => '',
                      'visibility' => 'Private',
                      'representative_id' => restricted_publication_open_file_set.id,
                      'filename' => nil,
                      'path' => nil
                    })
      expect(restricted_pub_metadata[1].to_hash)
        .to include({
                      'internal_id' => restricted_publication.id,
                      'member_id' => restricted_publication_open_file_set.id,
                      'type' => 'File',
                      'visibility' => 'Public',
                      'title' => nil,
                      'filename' => 'pdf-sample.pdf',
                      'path' => "#{restricted_publication.id}/pdf-sample.pdf",
                      'date_uploaded' => '1999-10-27',
                      'location_url' => "http://localhost:3000/downloads/#{restricted_publication_open_file_set.id}",
                      'representative_id' => nil,
                      'identifier' => nil,
                      'table_of_contents' => nil,
                      'abstract' => nil,
                      'series' => nil,
                      'issue_number' => nil,
                      'collection' => nil
                    })
    end
  end
end
