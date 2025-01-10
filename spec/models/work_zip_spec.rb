# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkZip, type: :model do
  subject(:work_zip) { described_class.new(work_id: publication.id) }

  let(:xmas) { Date.new(2017, 12, 25) }
  let(:file_path) { Rails.root.join('tmp', 'zip_exports', 'MyPublication_2017-12-25.zip') }

  let(:pdf_file) do
    File.open(file_fixture('pdf-sample.pdf')) { |file| create(:file_set, content: file) }
  end

  let(:image_file) do
    File.open(file_fixture('sir_mordred.jpg')) { |file| create(:file_set, content: file) }
  end

  let(:publication) do
    create(:publication, title: ['My Publication'], file_sets: [pdf_file, image_file])
  end

  before do
    DatabaseCleaner.clean_with(:truncation)
    ActiveFedora::Cleaner.clean!
  end

  describe '#create_zip' do
    before do
      allow(Date).to receive(:today).and_return(xmas)
      File.delete(file_path) if File.exist?(file_path)
    end

    after { File.delete(file_path) if File.exist?(file_path) }

    context 'a work file attached files' do
      it 'creates a zip with the files' do
        work_zip.create_zip

        # Check that zip file exists
        expect(work_zip.file_path).to eq file_path.to_s
        expect(File.file?(file_path)).to eq true

        # Check the zip contains the right files
        Zip::File.open(file_path) do |zip_file|
          file_names = zip_file.entries.map(&:name)
          expect(file_names).to contain_exactly('sir_mordred.jpg', 'pdf-sample.pdf')
        end
      end
    end

    context 'when attached files have the same name' do
      # Use the same file as the image_file so there will be a duplicate
      let(:pdf_file) do
        File.open(file_fixture('sir_mordred.jpg')) { |file| create(:file_set, content: file) }
      end

      it 'creates a zip with the files' do
        work_zip.create_zip
        expect(File.file?(file_path)).to eq true

        Zip::File.open(file_path) do |zip_file|
          file_names = zip_file.entries.map(&:name)
          expect(file_names.count).to eq 2
          expect(file_names).to contain_exactly('0_sir_mordred.jpg', '1_sir_mordred.jpg')
        end
      end
    end

    context 'when it fails' do
      subject(:work_zip) { described_class.new(work_id: 'some_fake_id') }

      it 'sets status to :failed' do
        work_zip.create_zip
        expect(work_zip.status).to eq 'failed'
        # also, because status is a ActiveRecord enum,
        expect(work_zip).to be_failed
      end
    end
  end

  describe '#file_name' do
    subject(:file_name) { work_zip.file_name(work_title) }

    before do
      allow(Date).to receive(:today).and_return(xmas)
    end

    context 'a title with spaces in the name' do
      let(:work_title) { 'A title with spaces that is longer than 30 characters' }

      it 'strips out the spaces and truncates' do
        expect(file_name).to eq "Atitlewithspacesthatislon_2017-12-25.zip"
      end
    end
  end

  describe '.latest' do
    subject(:latest) { described_class.latest(work_id) }

    let(:work_id) { '123' }
    let(:work_zip) { described_class.create(work_id: work_id) }
    let(:xmas_work_zip) { described_class.create(work_id: work_id, updated_at: xmas) }
    let(:belongs_to_another_work) { described_class.create(work_id: 'a_different_work') }

    context 'when there is more than one work_zip for a work' do
      before do
        # Create the WorkZip records
        [xmas_work_zip, work_zip, belongs_to_another_work]
      end

      it 'finds the most recent WorkZip for this work' do
        expect(described_class.count).to eq 3
        expect(latest).to eq [work_zip]
      end
    end

    context 'when there is no work_zip for a work' do
      before do
        # Create the WorkZip records
        belongs_to_another_work
      end

      it 'returns empty set' do
        expect(described_class.count).to eq 1
        expect(latest).to eq []
      end
    end
  end

  describe '#status' do
    subject { work_zip.status }
    let(:publication) { FactoryBot.build(:publication) }

    it 'is "unavilable" on initializtion' do
      expect(work_zip.status).to eq 'unavailable'
    end

    it 'is "failed" on errors' do
      work_zip.create_zip # fails because the publication is not persisted
      expect(work_zip.status).to eq 'failed'
    end

    it 'is "working" during zip creation' do
      publication.save!
      allow(work_zip).to receive(:working!)
      work_zip.create_zip
      expect(work_zip).to have_received(:working!)
    end

    it 'is "completed" after successful zip creation' do
      publication.save!
      work_zip.create_zip
      expect(work_zip.status).to eq 'completed'
    end
  end
end
