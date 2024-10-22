# frozen_string_literal: true
require 'rails_helper'
RSpec.describe Cypripedium::Attributes do
  let(:attributes) { described_class.to_a }
  let(:defined_attributes) do
    ["creator_id", "series", "issue_number", "abstract", "alternative_title",
     "bibliographic_citation", "corporate_name",
     "date_available", "extent", "has_part",
     "is_version_of", "has_version", "is_replaced_by",
     "replaces", "requires", "geographic_name",
     "table_of_contents", "temporal"]
  end
  describe '#to_a' do
    it 'returns the correct attributes' do
      expect(attributes).to eq(defined_attributes)
    end
  end
end
