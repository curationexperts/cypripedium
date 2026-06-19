# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExportJob, type: :job do
  let(:admin) { FactoryBot.create(:admin) }

  let(:pdf_file) do
    File.open(file_fixture('pdf-sample.pdf')) { |file| create(:file_set, content: file) }
  end

  let(:test_time) { Time.zone.parse('2020-01-15T12:00:00Z') }

  let(:publication) do
    FactoryBot.create(:publication,
           title: ['Test Publication'],
           creator: ['Smith, Jane', 'Jones, Bob'],
           corporate_name: ['Federal Reserve Bank of Minneapolis'],
           date_created: ['2020-01-15'],
           date_modified: test_time,
           abstract: ['A test abstract'],
           identifier: ['https://doi.org/10.21034/sr.999'],
           table_of_contents: ['Chapter 1; Chapter 2'],
           file_sets: [pdf_file])
  end

  let(:export) { FactoryBot.create(:export, user: admin, format: :bag, items: [publication.id]) }

  before :all do
    Hyrax::AdminSetCreateService.find_or_create_default_admin_set
  end

  after :all do
    ActiveFedora::Cleaner.clean!
  end

  describe 'status lifecycle' do
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
  end

  describe 'bag structure' do
    it 'includes files for the work in the bag' do
      described_class.perform_now(export)
      expect(zip_entry_names(export)).to include(a_string_matching(publication.id))
    end

    it 'includes a SHA-256 manifest' do
      described_class.perform_now(export)
      expect(zip_entry_names(export)).to include(a_string_matching('manifest-sha256.txt'))
    end

    it 'includes a metadata CSV at the bag root' do
      described_class.perform_now(export)
      expect(zip_entry_names(export)).to include(a_string_matching('metadata.csv'))
    end
  end

  describe 'metadata CSV' do
    subject(:csv) { parsed_csv(export) }

    before { described_class.perform_now(export) }

    it 'includes the correct headers' do
      expect(csv.headers).to eq ['title', 'name-creator', 'name-author', 'dateCreated',
                                 'dateModified', 'abstract', 'location-url',
                                 'identifier', 'tableOfContents']
    end

    it 'writes a row for the publication' do
      expect(csv.length).to eq 1
    end

    it 'maps metadata', :aggregate_failures do
      expect(csv[0].to_hash)
        .to eq({
                 # rubocop:disable Layout/HashAlignment
                 'title' => 'Test Publication',
                 'name-creator'    => 'Federal Reserve Bank of Minneapolis',
                 'name-author'     => 'Jones, Bob|Smith, Jane',
                 'dateCreated'     => '2020-01-15',
                 'dateModified'    => '2020-01-15T12:00:00+00:00',
                 'abstract'        => 'A test abstract',
                 'location-url'    => "http://localhost:3000/concern/publications/#{publication.id}",
                 'identifier'      => 'https://doi.org/10.21034/sr.999',
                 'tableOfContents' => 'Chapter 1; Chapter 2'
               })
    end

    context 'when items include multiple works' do
      let(:publication2) { create(:publication, title: ['Second Publication']) }
      let(:export) do
        FactoryBot.create(:export, user: admin, format: :bag,
                                   items: [publication.id, publication2.id])
      end

      it 'writes a row for each work' do
        expect(csv.length).to eq 2
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
      return CSV.parse(csv_entry.get_input_stream.read, headers: true)
    end
  end
end
