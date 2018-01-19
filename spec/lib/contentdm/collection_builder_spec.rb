# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Contentdm::CollectionBuilder do
  let(:name) { ['Sargent and Simms'] }
  let(:first_collection) { described_class.new(name) }
  let(:second_collection) { described_class.new(name) }

  context 'when initialized with a title' do
    describe '#find_or_create' do
      it 'creates a new collection with the given title' do
        collection = first_collection.find_or_create
        expect(collection.title).to eq(['Sargent and Simms'])
      end

      it 'loads an existing collection if one exists with that title' do
        collection_first = first_collection.find_or_create
        collection_second = second_collection.find_or_create
        expect(collection_first.id).to eq(collection_second.id)
      end
    end
  end
end
