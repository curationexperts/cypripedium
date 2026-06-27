# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExportsHelper, type: :helper do
  describe '#work_path' do
    it 'returns a path for ActiveFedora objects' do
      publication = FactoryBot.build(:publication, id: '1t2e3s4t')
      # Fake saving the object to speed up the test
      allow(publication).to receive(:persisted?).and_return(true)
      expect(helper.work_path(publication)).to eq '/concern/publications/1t2e3s4t'
    end

    it 'returns a path for Solr documents' do
      document = SolrDocument.new('id' => 'test12345', 'has_model_ssim' => ['Dataset'])
      expect(helper.work_path(document)).to eq '/concern/datasets/test12345'
    end

    it 'returns nil for incomplete Solr documents' do
      document = SolrDocument.new('id' => 'test56789')
      expect(helper.work_path(document)).to be_nil
    end

    it 'returns nil for unexpected objects' do
      foo = Object.new
      expect(helper.work_path(foo)).to be_nil
    end

    it 'returns nil for nil' do
      expect(helper.work_path(nil)).to be_nil
    end
  end
end
