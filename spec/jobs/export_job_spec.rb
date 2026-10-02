# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExportJob, type: :job do
  let(:admin) { FactoryBot.create(:admin) }

  let(:publication) { @publication }
  let(:restricted_publication) { @publication2 }
  let(:file_set) { @pdf }
  let(:restricted_publication_open_file_set) { @pdf_alt }

  let(:export) { FactoryBot.create(:export, user: admin, format: :bag, items: [publication.id]) }

  before(:all) do
    Hyrax::AdminSetCreateService.find_or_create_default_admin_set

    pdf_path = Rails.root.join('spec', 'fixtures', 'files', 'pdf-sample.pdf')
    @pdf     = FactoryBot.create(:file_set, content: File.open(pdf_path), visibility: 'open', date_uploaded: Time.zone.parse('2020-07-31'))
    @pdf_dup = FactoryBot.create(:file_set, content: File.open(pdf_path), visibility: 'restricted')
    @pdf_alt = FactoryBot.create(:file_set, content: File.open(pdf_path), visibility: 'open', date_uploaded: Time.zone.parse('1999-10-27'))
    @txt = FactoryBot.create(:file_set, content: File.open(Rails.root.join('spec', 'fixtures', 'files', 'tiny.txt')), visibility: 'authenticated')

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

  describe 'status lifecycle' do
    it 'sets status to :queued when queued', :aggregate_failures do
      expect(export.status).to eq 'unknown'
      described_class.perform_later(export)
      expect(export.reload.status).to eq 'queued'
    end

    it 'sets status to :completed on success', :aggregate_failures do
      expect(export).to receive(:working!)
      described_class.perform_now(export)
      expect(export.reload.status).to eq 'completed'
    end

    it 'sets status to :failed with an error message when a work id cannot be found', :aggregate_failures do
      export.update!(items: ['nonexistent_id'])
      described_class.perform_now(export)
      expect(export.reload.status).to eq 'failed'
      expect(export.reload.message).to be_present
    end

    it 'sets status to :failed for unsupported work types', :aggregate_failures do
      collection = Collection.new(
        title: ['Test Collection'],
        collection_type: Hyrax::CollectionType.find_or_create_default_collection_type
      ).tap(&:save!)
      export.update!(items: [collection.id])
      described_class.perform_now(export)
      expect(export.reload.status).to eq 'failed'
      expect(export.reload.message).to match(/unsupported work type/i)
    end
  end

  describe 'ActiveStorage attachment' do
    it 'attaches the zip file to the export on success' do
      described_class.perform_now(export)
      expect(export.reload.export_file).to be_attached
    end

    context 'with invalid item IDs' do
      let(:export) { FactoryBot.create(:export, user: admin, format: :bag, items: ['nonexistent_id']) }
      it 'does not attach a file on failure' do
        described_class.perform_now(export)
        expect(export.reload.export_file).not_to be_attached
      end
    end

    describe 'filename' do
      it 'has the expected default' do
        default_filename = export.default_filename # capture now to avoide deduplication issues
        described_class.perform_now(export)
        attachment = export.reload.export_file
        expect(attachment.filename.to_s).to match(default_filename)
      end

      context 'when overridden' do
        let(:export) { FactoryBot.create(:export, user: admin, format: :bag, items: [publication.id], filename: 'my_export') }
        it 'uses the user supplied value' do
          described_class.perform_now(export)
          attachment = export.reload.export_file
          expect(attachment.filename.to_s).to eq 'my_export.zip'
        end
      end
    end
  end

  describe 'bag structure' do
    it 'includes files for the work in the bag' do
      described_class.perform_now(export)
      expect(zip_entry_names(export)).to include(a_string_matching(publication.id))
    end

    it 'contains required files' do
      described_class.perform_now(export)
      zip_names = zip_entry_names(export)
      expect(zip_names).to include(a_string_matching(%r{/bagit.txt\z}))
      expect(zip_names).to include(a_string_matching(%r{/bag-info.txt\z}))
      expect(zip_names).to include(a_string_matching(%r{/manifest-sha256.txt\z}))
      expect(zip_names).to include(a_string_matching(%r{/tagmanifest-sha1.txt\z}))
      expect(zip_names).to include(a_string_matching(%r{/metadata.csv\z}))
      expect(zip_names).to include(a_string_matching('/data/'))
      expect(zip_names).to include(a_string_matching('/metadata/'))
    end

    describe 'metadata CSV' do
      let(:publication) { FactoryBot.create(:publication, visibility: 'open', file_sets: []) }
      it 'includes the expected columns' do
        described_class.perform_now(export)
        csv = parsed_csv(export)
        expect(csv.headers)
          .to include(
                # NOTE: this is a subset of the columns in the CSV, not a definitive list
                'title',
                'creator',
                'corporate_author',
                'date_created',
                'location_url',
                'identifier',
                'series',
                'issue_number',
                'collection',
                'abstract',
                'table_of_contents'
              )
      end

      it 'includes works with no files attached' do
        described_class.perform_now(export)
        csv = parsed_csv(export)
        expect(csv.length).to eq 1
      end
    end
  end

  describe 'temporary file cleanup' do
    it 'removes the temporary directory after success' do
      tmp_dir = nil
      allow(Dir).to receive(:mktmpdir).and_wrap_original do |original, *args, &block|
        original.call(*args) do |dir|
          tmp_dir = dir
          block.call(dir)
        end
      end
      described_class.perform_now(export)
      expect(Dir.exist?(tmp_dir)).to be false
    end

    it 'removes the temporary directory after failure' do
      tmp_dir = nil
      allow(Dir).to receive(:mktmpdir).and_wrap_original do |original, *args, &block|
        original.call(*args) do |dir|
          tmp_dir = dir
          block.call(dir)
        end
      end
      export.update!(items: ['nonexistent_id'])
      described_class.perform_now(export)
      expect(Dir.exist?(tmp_dir)).to be false
    end
  end

  describe 'visibility filtering' do
    let(:export) { FactoryBot.create(:export, user: admin, format: :bag, items: [publication.id, restricted_publication.id], filename: 'test_export') }

    it 'only includes "open" files in "open" exports', :aggregate_failures do
      export.update!(visibility: 'open')

      # notification count check - two items in export, but one should be filtered out
      expect(admin).to receive(:send_message).with(
        admin,
        a_string_matching(/containing 1 item\s+is available for download/i),
        a_string_matching(/completed/i)
      )

      described_class.perform_now(export)

      # payload checks
      zip_names = zip_entry_names(export)
      data_files = zip_names.select { |e| e.match?('/data/.*[^/]\z') }
      expect(data_files.length).to eq 1
      expect(data_files).to include(a_string_matching(publication.id))
      expect(data_files).to include(a_string_matching('/0/pdf-sample.pdf'))
      expect(data_files).not_to include(a_string_matching('/1/pdf-sample.pdf'))
      expect(data_files).not_to include(a_string_matching('/2/tiny.txt'))
      expect(data_files).not_to include(a_string_matching(restricted_publication.id))

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
                      'path' => "data/#{publication.id}/0/pdf-sample.pdf",
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
      described_class.perform_now(export)
      zip_names = zip_entry_names(export)
      data_files = zip_names.select { |e| e.match?('/data/.*[^/]\z') }
      expect(data_files.length).to eq 2
      expect(data_files).to include(a_string_matching(publication.id))
      expect(data_files).to include(a_string_matching('/0/pdf-sample.pdf'))
      expect(data_files).not_to include(a_string_matching('/1/pdf-sample.pdf'))
      expect(data_files).to include(a_string_matching('/2/tiny.txt'))
      expect(data_files).not_to include(a_string_matching(restricted_publication.id))
    end

    it 'includes all files in "restricted" exports', :aggregate_failures do
      export.update!(visibility: 'restricted')
      described_class.perform_now(export)
      zip_names = zip_entry_names(export)
      data_files = zip_names.select { |e| e.match?('/data/.*[^/]\z') }

      # structure checks
      expect(data_files.length).to eq 4
      expect(data_files).to include(a_string_matching(publication.id))
      expect(data_files).to include(a_string_matching('/0/pdf-sample.pdf'))
      expect(data_files).to include(a_string_matching('/1/pdf-sample.pdf'))
      expect(data_files).to include(a_string_matching('/2/tiny.txt'))
      expect(data_files).to include(a_string_matching(restricted_publication.id))

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
                      'path' => "data/#{restricted_publication.id}/0/pdf-sample.pdf",
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

  describe 'user notification' do
    context 'when the submitting user is an admin' do
      it 'sends a success notification on completion' do
        expect(admin).to receive(:send_message).with(
          admin,
          a_string_matching(/export/i),
          a_string_matching(/completed/i)
        )
        described_class.perform_now(export)
      end

      it 'sends a failure notification on error' do
        export.update!(items: ['nonexistent_id'])
        expect(admin).to receive(:send_message).with(
          admin,
          a_string_matching(/export/i),
          a_string_matching(/failed/i)
        )
        described_class.perform_now(export)
      end
    end

    context 'when the submitting user is not an admin' do
      let(:export) { FactoryBot.create(:export, user: User.system_user, format: :bag, items: [publication.id]) }

      it 'does not send a notification' do
        expect(User.system_user).not_to receive(:send_message)
        described_class.perform_now(export)
      end
    end
  end

  private

  def zip_entry_names(export)
    export.reload
    return [] unless export.export_file.attached?
    Zip::File.open_buffer(export.export_file.download) do |zip|
      return zip.map(&:name)
    end
  end

  def parsed_csv(export)
    export.reload
    return CSV::Table.new([]) unless export.export_file.attached?
    Zip::File.open_buffer(export.export_file.download) do |zip|
      csv_entry = zip.find { |e| e.name.end_with?('metadata.csv') }
      return CSV.parse(csv_entry.get_input_stream.read, headers: true, skip_blanks: true)
    end
  end
end
