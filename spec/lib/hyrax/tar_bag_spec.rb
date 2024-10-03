# frozen_string_literal: true

require 'rails_helper'
require 'fileutils'

RSpec.describe Hyrax::TarBag, type: :model do
  subject(:work_bag) { described_class.new(work_ids: [publication.id, publication2.id], time_stamp: time_stamp) }
  let(:time_stamp) { 109_092 }
  let(:file_path) { Rails.application.config.bag_path }

  let(:pdf_file) do
    File.open(file_fixture('pdf-sample.pdf')) { |file| create(:file_set, content: file) }
  end

  let(:image_file) do
    File.open(file_fixture('sir_mordred.jpg')) { |file| create(:file_set, content: file) }
  end

  let(:publication) do
    create(:publication, title: ['My Publication'], file_sets: [pdf_file, image_file])
  end

  let(:publication2) do
    create(:publication, title: ['My Publication 2'], file_sets: [pdf_file, image_file])
  end

  describe '#create' do
    after do
      FileUtils.rm_rf(file_path)
    end

    context 'a work file attached files' do
      let(:expected_files) {
        [
          "mpls_fed_research_109092",
          "mpls_fed_research_109092/bag-info.txt",
          "mpls_fed_research_109092/bagit.txt",
          "mpls_fed_research_109092/data",
          %r{mpls_fed_research_109092/data/\w{9}},
          %r{mpls_fed_research_109092/data/\w{9}/\w{9}\.xml},
          %r{mpls_fed_research_109092/data/\w{9}/pdf-sample.pdf},
          %r{mpls_fed_research_109092/data/\w{9}/sir_mordred.jpg},
          "mpls_fed_research_109092/manifest-sha256.txt",
          "mpls_fed_research_109092/tagmanifest-md5.txt",
          "mpls_fed_research_109092/tagmanifest-sha1.txt"
        ]
      }

      it 'creates a bag from the works', :aggregate_failures do
        work_bag.create

        # Get the entries in the tar bag
        entries = []
        File.open("#{work_bag.bag_path}.tar") do |io|
          Gem::Package::TarReader.new(io) do |tar|
            entries = tar.map(&:full_name)
          end
        end

        expect(entries.length).to eq 15
        expect(entries).to include(*expected_files)
      end
    end
  end
end
