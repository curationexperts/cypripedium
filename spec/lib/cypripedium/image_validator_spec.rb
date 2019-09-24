# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Cypripedium::ImageValidator do
  let(:corrupted_file) { Rails.root.join('spec', 'fixtures', 'images', 'corrupted', 'corrupt.png') }
  let(:good_file) { Rails.root.join('spec', 'fixtures', 'images', 'good', 'watermelon.png') }
  let(:image_validator_with_corrupted_file) { described_class.new(image: corrupted_file) }
  let(:image_validator) { described_class.new(image: good_file) }

  describe '#valid?' do
    it 'returns false if the image is corrupted' do
      expect(image_validator_with_corrupted_file.valid?).to eq(false)
    end

    it 'returns true if the image is valid' do
      expect(image_validator.valid?).to eq(true)
    end
  end
end
