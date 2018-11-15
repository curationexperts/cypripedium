require 'rails_helper'
require 'fileutils'

RSpec.describe Bag, type: :model do
  subject(:work_bag) { described_class.new(work_id: publication.id, time_stamp: time_stamp) }

  let(:tar_size) { 104_448 }
  let(:time_stamp) { 109_092 }
  let(:file_path) { Rails.root.join('tmp', 'bags', publication.id) }

  let(:pdf_file) do
    File.open(file_fixture('pdf-sample.pdf')) { |file| create(:file_set, content: file) }
  end

  let(:image_file) do
    File.open(file_fixture('sir_mordred.jpg')) { |file| create(:file_set, content: file) }
  end

  let(:publication) do
    create(:publication, title: ['My Publication'], file_sets: [pdf_file, image_file])
  end

  describe '#create' do
    before do
      FileUtils.rm_rf(file_path)
      FileUtils.mkdir(Rails.root.join('tmp', 'bags'))
    end

    after do
      FileUtils.rm_rf(file_path)
      FileUtils.rm_rf("#{file_path}.tar.gz")
    end

    context 'a work file attached files' do
      it 'creates a bag with the files' do
        work_bag.create

        # Expect the tar file to be created
        # and expect it to be the correct size
        expect(File.exist?("#{work_bag.bag_path}.tar")).to eq true
        expect(File.size("#{work_bag.bag_path}.tar")).to eq tar_size
      end
    end
  end
end
