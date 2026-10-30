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
    @pdf     = FactoryBot.create(:file_set, content: File.open(pdf_path), visibility: 'open', date_uploaded: Time.zone.parse('2020-07-31'), title: ['Sample PDF v1'])
    @pdf_dup = FactoryBot.create(:file_set, content: File.open(pdf_path), visibility: 'restricted')
    @pdf_alt = FactoryBot.create(:file_set, content: File.open(pdf_path), visibility: 'open', date_uploaded: Time.zone.parse('1999-10-27'), title: ['Public File on Restricted Publication'])
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

  # describe '#metadata_csv' do
  #   let(:work)   { FactoryBot.build(:publication, id: 'abc123', visibility: 'open', file_sets: []) }
  #   let(:export) { FactoryBot.create(:export, format: :zip, items: ['abc123'], filename: 'test_export') }
  #
  #   before { allow(ActiveFedora::Base).to receive(:find).with('abc123').and_return(work) }
  #
  #   it 'includes works with no files attached' do
  #     described_class.package_items(export)
  #     expect(parsed_csv(export)['internal_id']).to eq ['abc123']
  #   end
  #
  #   # Test for the order of specific columns, not intended to be comprehensive
  #   it 'orders key header columns' do
  #     described_class.package_items(export)
  #     headers = parsed_csv(export).headers
  #     expect(headers.first(4)).to eq ['internal_id', 'member_id', 'type', 'visibility']
  #     expect(headers.last(2)).to eq ['abstract', 'table_of_contents'] # potentially long strings should go to the end
  #   end
  # end

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

  # describe 'visibility filtering' do
  #   let(:export) { FactoryBot.create(:export, format: :zip, items: [publication.id, restricted_publication.id], filename: 'test_export') }
  #
  #   it 'only includes "open" files in "open" exports', :aggregate_failures do
  #     # Because this is the shortest export, we change the format to :bag to ensure we're testing end-to-end
  #     # BagIt export functionality with real fedora objects. The BagWriter tests generally use mocks.
  #     export.update!(format: :bag, visibility: 'open')
  #
  #     item_count = described_class.package_items(export)
  #     expect(item_count).to eq 1
  #
  #     # payload checks
  #     zip_names = zip_filenames(export).map { |path| path.delete_prefix("test_export/") }
  #     expect(zip_names).to contain_exactly(
  #                            'bagit.txt',
  #                            'bag-info.txt',
  #                            'manifest-sha256.txt',
  #                            'tagmanifest-md5.txt',
  #                            'tagmanifest-sha1.txt',
  #                            'metadata.csv',
  #                            "metadata/#{publication.id}.json",
  #                            "data/#{publication.id}/pdf-sample.pdf"
  #                          )
  #
  #     # metadata checks
  #     csv = parsed_csv(export)
  #     expect(csv.length).to eq 2 # work + fileset
  #     expect(csv[0].to_hash)
  #       .to include({
  #                     'internal_id' => publication.id,
  #                     'member_id' => nil,
  #                     'type' => 'Publication',
  #                     'title' => 'Test Publication',
  #                     'corporate_author' => 'Federal Reserve Bank of Minneapolis',
  #                     'creator' => 'Gordon, Robert J.|Smith, Jane',
  #                     'date_created' => '2020-01-15',
  #                     'date_modified' => '2020-01-15',
  #                     'date_uploaded' => '2019-04-11',
  #                     'abstract' => 'A test abstract',
  #                     'location_url' => "http://localhost:3000/concern/publications/#{publication.id}",
  #                     'identifier' => 'https://doi.org/10.21034/sr.999',
  #                     'table_of_contents' => 'Chapter 1; Chapter 2',
  #                     'series' => a_string_matching(/Series 1/), # Hyrax doesn't guarantee order of series
  #                     'issue_number' => 'Vol. 44, No. 4',
  #                     'collection' => '',
  #                     'visibility' => 'Public',
  #                     'representative_id' => file_set.id,
  #                     'filename' => nil,
  #                     'path' => nil
  #                   })
  #     expect(csv[1].to_hash)
  #       .to include({
  #                     'internal_id' => publication.id,
  #                     'member_id' => file_set.id,
  #                     'type' => 'File',
  #                     'visibility' => 'Public',
  #                     'title' => 'Sample PDF v1',
  #                     'filename' => 'pdf-sample.pdf',
  #                     'path' => "#{publication.id}/pdf-sample.pdf",
  #                     'date_uploaded' => '2020-07-31',
  #                     'location_url' => "http://localhost:3000/downloads/#{file_set.id}",
  #                     'representative_id' => nil,
  #                     'identifier' => nil,
  #                     'table_of_contents' => nil,
  #                     'abstract' => nil,
  #                     'series' => nil,
  #                     'issue_number' => nil,
  #                     'collection' => nil
  #                   })
  #   end
  #
  #   it 'omits "restricted" files from "authenticated" exports', :aggregate_failures do
  #     export.update!(visibility: 'authenticated')
  #     described_class.package_items(export)
  #     zip_names = zip_filenames(export)
  #     expect(zip_names).to contain_exactly(
  #                             "test_export/metadata.csv",
  #                             "test_export/#{publication.id}/1/pdf-sample.pdf",
  #                             "test_export/#{publication.id}/2/tiny.txt"
  #                             # does not include the restricted fileset
  #                           )
  #   end
  #
  #   it 'includes all files in "restricted" exports', :aggregate_failures do
  #     export.update!(visibility: 'restricted')
  #     described_class.package_items(export)
  #     zip_names = zip_filenames(export)
  #
  #     # structure checks
  #     expect(zip_names).to contain_exactly(
  #                            "test_export/metadata.csv",
  #                             "test_export/#{publication.id}/1/pdf-sample.pdf",
  #                             "test_export/#{publication.id}/2/pdf-sample.pdf",
  #                             "test_export/#{publication.id}/3/tiny.txt",
  #                             "test_export/#{restricted_publication.id}/pdf-sample.pdf"
  #                           )
  #
  #     # metadata checks
  #     csv = parsed_csv(export)
  #     expect(csv.length).to eq 6 # public work + fileset x3 + restricted work + fileset
  #
  #     # Work rows are ordered by ID (randomly assigned NOID), so we can't rely on the overall order of the CSV rows,
  #     # But the metadata and fileset order within a work are predictable
  #     restricted_pub_metadata = csv.select { |r| r['internal_id'] == restricted_publication.id }
  #     expect(restricted_pub_metadata[0].to_hash)
  #       .to include({
  #                     'internal_id' => restricted_publication.id,
  #                     'member_id' => nil,
  #                     'type' => 'Publication',
  #                     'title' => 'Restricted Publication',
  #                     'corporate_author' => 'Federal Reserve Bank of Minneapolis',
  #                     'creator' => '', # we don't support string creator names
  #                     'date_created' => '2020-01-10',
  #                     'date_uploaded' => nil, # shouldn't happen in real life, but testing here for robustness
  #                     'date_modified' => '2020-01-15',
  #                     'abstract' => 'A test abstract',
  #                     'location_url' => "http://localhost:3000/concern/publications/#{restricted_publication.id}",
  #                     'identifier' => 'https://doi.org/10.21034/sr.888',
  #                     'table_of_contents' => 'Introduction, One, Two, Appendix',
  #                     'series' => '',
  #                     'issue_number' => '',
  #                     'collection' => '',
  #                     'visibility' => 'Private',
  #                     'representative_id' => restricted_publication_open_file_set.id,
  #                     'filename' => nil,
  #                     'path' => nil
  #                   })
  #     expect(restricted_pub_metadata[1].to_hash)
  #       .to include({
  #                     'internal_id' => restricted_publication.id,
  #                     'member_id' => restricted_publication_open_file_set.id,
  #                     'type' => 'File',
  #                     'visibility' => 'Public',
  #                     'title' => 'Public File on Restricted Publication',
  #                     'filename' => 'pdf-sample.pdf',
  #                     'path' => "#{restricted_publication.id}/pdf-sample.pdf",
  #                     'date_uploaded' => '1999-10-27',
  #                     'location_url' => "http://localhost:3000/downloads/#{restricted_publication_open_file_set.id}",
  #                     'representative_id' => nil,
  #                     'identifier' => nil,
  #                     'table_of_contents' => nil,
  #                     'abstract' => nil,
  #                     'series' => nil,
  #                     'issue_number' => nil,
  #                     'collection' => nil
  #                   })
  #   end
  # end
end

# Stubs all Fedora interactions in ExportPackager to produce a fast test suite.
# See "fedora_export_packager_spec.rb" for examples that test the full Fedora persistence stack.
RSpec.describe ExportPackager do
  include_context 'export helpers'

  let(:export) { FactoryBot.build(:export, id: 4321, items: ['abc123'], filename: 'test_export') }
  let(:packager) { described_class.new(export) }
  let(:work) {
    FactoryBot.build(:publication,
                     id: 'abc123',
                     visibility: 'open',
                     representative_id: 'fs1',
                     title: ['Test Work'],
                     creator_id: [creator.id],
                     corporate_name: ['Federal Reserve Bank of Minneapolis'],
                     date_created: ['1986-07-23'],
                     date_uploaded: Time.zone.parse('2019-04-11'),
                     date_modified: Time.zone.parse('2020-01-15T14:34:27Z'),
                     abstract: ['A test abstract'],
                     identifier: ['https://doi.org/10.21034/sr.999'],
                     table_of_contents: ['Chapter 1; Chapter 2'],
                     series: ['Series 1', 'Series 2'],
                     issue_number: ['Vol. 44, No. 4'])
  }
  let(:fs1) {
    FactoryBot.build(:file_set, id: 'fs1', visibility: 'open',
                                title: ['First File'], date_uploaded: Time.zone.parse('2020-07-31'))
  }
  let(:creator) { FactoryBot.create(:creator, display_name: 'Smith, Jane') }

  before do
    allow(Rails.error).to receive(:report)
    allow(work).to receive(:persisted?).and_return(true)
    allow(ActiveFedora::Base).to receive(:find).with('abc123').and_return(work)
    allow(fs1).to receive_messages(
                    persisted?: true,
                    original_file: instance_double(Hydra::PCDM::File, file_name: ['a.pdf'], content: 'pdf bytes')
                  )
  end

  describe '.package_items' do
    let(:export) { FactoryBot.create(:export, items: ['abc123', 'def456'], filename: 'test_export') }
    let(:private_work) { FactoryBot.build(:publication, id: 'def456', visibility: 'restricted') }
    let(:child_work) { FactoryBot.build(:publication, id: 'child123', visibility: 'open') }
    let(:fs2) { FactoryBot.build(:file_set, id: 'fs2', visibility: 'restricted') }
    let(:fs3) {
      FactoryBot.build(:file_set, id: 'fs3', visibility: 'open',
                                  title: ['Third File'], date_uploaded: Time.zone.parse('2021-03-15'))
    }

    before do
      allow(work).to receive(:ordered_members).and_return([fs1, fs2, child_work, fs3])
      allow(ActiveFedora::Base).to receive(:find).with('def456').and_return(private_work)
      allow(fs3).to receive_messages(
                      persisted?: true,
                      original_file: instance_double(Hydra::PCDM::File, file_name: ['c.txt'], content: 'text bytes')
                    )
    end

    it 'saves visible items to the attached archive', :aggregate_failures do
      expect(described_class.package_items(export)).to eq 1 # 1 work exported
      expect(export.export_file.filename.to_s).to eq 'test_export.zip' # testing the overridden file name
      expect(zip_filenames(export)).to eq ["test_export/abc123/1/a.pdf",
                                           "test_export/abc123/2/c.txt",
                                           "test_export/metadata.csv"]
      csv = parsed_csv(export)
      expect(csv.headers).to eq described_class::METADATA_HEADERS.map(&:to_s)
      expect(csv.size).to eq 3
      expect(csv[0].to_h).to eq(
                               { "internal_id" => "abc123",
                                 "member_id" => nil,
                                 "type" => "Publication",
                                 "visibility" => "Public",
                                 "representative_id" => 'fs1',
                                 "title" => "Test Work",
                                 "creator" => "Smith, Jane",
                                 "corporate_author" => "Federal Reserve Bank of Minneapolis",
                                 "date_created" => '1986-07-23',
                                 "date_uploaded" => "2019-04-11",
                                 "date_modified" => "2020-01-15",
                                 "location_url" => "http://localhost:3000/concern/publications/abc123",
                                 "identifier" => "https://doi.org/10.21034/sr.999",
                                 "filename" => nil,
                                 "path" => nil,
                                 "series" => "Series 1|Series 2",
                                 "issue_number" => "Vol. 44, No. 4",
                                 "collection" => "",
                                 "abstract" => "A test abstract",
                                 "table_of_contents" => "Chapter 1; Chapter 2",
                                 "error" => nil }
                             )
      expect(csv[1].to_h).to eq(
                               { "internal_id" => "abc123",
                                 "member_id" => "fs1",
                                 "type" => "File",
                                 "visibility" => "Public",
                                 "representative_id" => nil,
                                 "title" => "First File",
                                 "creator" => nil,
                                 "corporate_author" => nil,
                                 "date_created" => nil,
                                 "date_uploaded" => "2020-07-31",
                                 "date_modified" => nil,
                                 "location_url" => "http://localhost:3000/downloads/fs1",
                                 "identifier" => nil,
                                 "filename" => "a.pdf",
                                 "path" => "abc123/1/a.pdf",
                                 "series" => nil,
                                 "issue_number" => nil,
                                 "collection" => nil,
                                 "abstract" => nil,
                                 "table_of_contents" => nil,
                                 "error" => nil }
                             )

      expect(csv[2].to_h).to eq(
                               { "internal_id" => "abc123",
                                 "member_id" => "fs3",
                                 "type" => "File",
                                 "visibility" => "Public",
                                 "representative_id" => nil,
                                 "title" => "Third File",
                                 "creator" => nil,
                                 "corporate_author" => nil,
                                 "date_created" => nil,
                                 "date_uploaded" => "2021-03-15",
                                 "date_modified" => nil,
                                 "location_url" => "http://localhost:3000/downloads/fs3",
                                 "identifier" => nil,
                                 "filename" => "c.txt",
                                 "path" => "abc123/2/c.txt",
                                 "series" => nil,
                                 "issue_number" => nil,
                                 "collection" => nil,
                                 "abstract" => nil,
                                 "table_of_contents" => nil,
                                 "error" => nil }
                             )
    end

    context 'for works with no files attached' do
      before do
        allow(work).to receive(:ordered_members).and_call_original # undo the stub on ordered_members
      end

      it 'exports work-level metadata' do
        described_class.package_items(export)
        expect(parsed_csv(export)['internal_id']).to eq ['abc123'] # i.e. only one work row, no files
      end
    end

    context 'when errors are encountered' do
      let(:export) { FactoryBot.create(:export, visibility: 'restricted', items: ['abc123', 'def456'], filename: 'test_export') }
      before do
        allow(ActiveFedora::Base).to receive(:find).with('abc123').and_raise(Ldp::Gone, '')
        allow(private_work).to receive(:ordered_members).and_return([fs1, fs2, child_work, fs3])
        allow(fs2).to receive(:persisted?).and_return(true)
        allow(fs2).to receive(:original_file).and_raise(RuntimeError, 'bad file')
      end

      it 'exports the remaining works and files', :aggregate_failures do
        pending('Detailed error reporting is not yet implemented')
        expect(described_class.package_items(export)).to eq 1 # one errored work excluded from count
        csv = parsed_csv(export)
        expect(csv.size).to eq 5 # 2 works + 3 files
        # rubocop:disable Layout/ExtraSpacing, Layout/SpaceInsideArrayLiteralBrackets
        expect(csv['internal_id']).to eq ['abc123',   'def456', 'def456', 'def456',  'def456']
        expect(csv['member_id']).to eq   [ nil,        nil,     'fs1',    'fs2',     'fs3'   ]
        expect(csv['error']).to eq       ['Ldp::Gone', nil,      nil,     'bad file', nil    ]
        # rubocop:enable Layout/ExtraSpacing, Layout/SpaceInsideArrayLiteralBrackets
      end

      it 'separates works with a blank row' do
        pending('Detailed error reporting is not yet implemented')
        described_class.package_items(export)
        table = CSV.parse(zip_entry(export, 'test_export/metadata.csv'), headers: true)
        ids = table.map { |row| row['member_id'] || row['internal_id'] }
        expect(ids).to eq ['abc123', nil, 'def456', 'fs1', 'fs2', 'fs3', nil]
      end
    end
  end

  describe '#add_item' do
    let(:rows) { packager.instance_variable_get(:@metadata_rows) }
    let(:item_count) { packager.instance_variable_get(:@item_count) }
    let(:writer) { instance_double(ExportPackager::ZipWriter, write_item_metadata: nil) }

    before do
      allow(packager).to receive(:writer).and_return(writer)
    end

    context 'with an unsupported item type' do
      before do
        # allow(ActiveFedora::Base).to receive(:find).with('abc123').and_return(Collection.new)

        packager.send(:add_item, 'abc123')
      end

      it 'records an error row in place of the item', :aggregate_failures do
        skip('Detailed error reporting is not yet implemented')
        expect(rows).to eq [{ internal_id: 'abc123', error: 'Unsupported work type: Collection' }, []]
        expect(item_count).to eq 0
      end

      it 'reports the error with context' do
        skip('Detailed error reporting is not yet implemented')
        expect(Rails.error).to have_received(:report).with(
          an_instance_of(RuntimeError).and(having_attributes(message: 'Unsupported work type: Collection')),
          context: { export_id: 4321, work_id: 'abc123' }
        )
      end
    end

    context 'with a message-less error' do
      before do
        # The actual failure we saw in production when ordered_members had been tombstoned for some reason
        # allow(work).to receive(:ordered_members).and_raise(Ldp::Gone, '')

        packager.send(:add_item, 'abc123')
      end

      it 'uses the error class name' do
        skip('Detailed error reporting is not yet implemented')
        expect(rows[0]).to include(internal_id: 'abc123', error: 'Ldp::Gone')
      end

      it 'does not change the item count' do
        skip('Detailed error reporting is not yet implemented')
        expect(item_count).to eq 0
      end

      it 'includes work-level metadata in the error row' do
        skip('Detailed error reporting is not yet implemented')
        expect(rows[0]).to include(
                             internal_id: 'abc123',
                             type: 'Publication',
                             visibility: 'Public',
                             representative_id: 'fs1',
                             title: 'Test Work',
                             corporate_author: 'Federal Reserve Bank of Minneapolis',
                             location_url: 'http://localhost:3000/concern/publications/abc123',
                             date_created: '1986-07-23',
                             date_uploaded: '2019-04-11',
                             date_modified: '2020-01-15',
                             series: "Series 1|Series 2",
                             issue_number: "Vol. 44, No. 4",
                             collection: "",
                             abstract: "A test abstract",
                             table_of_contents: "Chapter 1; Chapter 2"
                           )
      end
    end
  end

  describe '#add_member' do
    let(:writer) { instance_double(ExportPackager::ZipWriter) }
    let(:row) { packager.send(:add_member, 'abc123', fs1, 'abc123/') }

    before do
      allow(packager).to receive(:writer).and_return(writer)
    end

    context 'with a file write error' do
      before do
        allow(writer).to receive(:write_content).and_raise(IOError, 'disk full')
      end

      it 'records the error and intended path on the file row' do
        expect(row).to include(internal_id: 'abc123', member_id: 'fs1', path: 'abc123/a.pdf', error: 'disk full')
      end

      it 'reports the error with context' do
        row # force row to build to trigger the error
        expect(Rails.error).to have_received(:report).with(
          an_instance_of(IOError).and(having_attributes(message: 'disk full')),
          context: { export_id: 4321, work_id: 'abc123', file_set_id: 'fs1', directory: 'abc123/' }
        )
      end
    end

    context 'with a message-less error' do
      before do
        allow(writer).to receive(:write_content).and_raise(Ldp::Gone, '')
      end

      it 'uses the error class name' do
        expect(row).to include(error: 'Ldp::Gone')
      end
    end
  end

  describe '#writer' do
    let(:tmp_dir) { Dir.mktmpdir }
    let(:writer) { packager.send(:writer) }

    before do
      packager.instance_variable_set(:@tmp_dir, tmp_dir)
    end

    after do
      FileUtils.remove_entry(tmp_dir)
    end

    context 'for a bag export' do
      before { export.format = 'bag' }

      it 'is a BagWriter', :aggregate_failures do
        expect(writer).to be_a ExportPackager::BagWriter
        expect(File).to exist(File.join(tmp_dir, 'archive', 'bagit.txt'))
      end
    end

    context 'for a zip export' do
      before { export.format = 'zip' }

      it 'is a ZipWriter', :aggregate_failures do
        expect(writer).to be_a ExportPackager::ZipWriter
        expect(File).to exist(File.join(tmp_dir, 'archive'))
      end
    end
  end

  describe '#padded_index' do
    context 'with a single item' do
      it 'returns a blank string' do
        expect(packager.send(:padded_index, 1, 1)).to eq ''
      end
    end

    context 'with 10 or more items' do
      it 'returns a zero padded index' do
        expect(packager.send(:padded_index, 4, 11)).to eq '04'
      end
    end
  end

  describe '#compress_archive' do
    it 'deletes working files after zipping' do
      Dir.mktmpdir do |tmp_dir|
        packager.instance_variable_set(:@tmp_dir, tmp_dir)

        # Write a dummy CSV file to the archive directory.
        # This is a stand-in for all the working files generated by the rest of the packager
        FileUtils.mkdir_p(File.join(tmp_dir, 'archive'))
        File.write(File.join(tmp_dir, 'archive', 'metadata.csv'), 'dummy csv content...')

        packager.send(:compress_archive)

        # Aftert compressing, we expect working files to be gone and only the zip archive to remain.
        expect(Dir.glob('**/*', base: tmp_dir)).to eq ['export.zip']
      end
    end
  end
end
