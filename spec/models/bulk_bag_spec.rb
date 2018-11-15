# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BulkBag do
  let(:bulk_bag) { described_class.new(ids: ids) }
  let(:bags_path) { Rails.root.join('tmp', 'bags') }
  let(:pdf_file) do
    File.open(file_fixture('pdf-sample.pdf')) { |file| create(:file_set, content: file) }
  end

  let(:image_file) do
    File.open(file_fixture('sir_mordred.jpg')) { |file| create(:file_set, content: file) }
  end

  let(:publication) do
    create(:publication, title: ['My Publication'], file_sets: [pdf_file, image_file])
  end
  let(:second_publication) do
    create(:publication, title: ['My Publication 2'], file_sets: [pdf_file, image_file])
  end

  let(:ids) do
    [publication.id, second_publication.id]
  end

  before do
    FileUtils.rm_rf(bags_path) if File.directory?(bags_path)
    FileUtils.mkdir(bags_path)
  end

  after do
    FileUtils.rm_rf(bags_path) if File.directory?(bags_path)
  end

  it 'creates bags from a list of ids' do
    bulk_bag.create
    expect(Dir.entries(bags_path).length).to eq 4
  end
end
