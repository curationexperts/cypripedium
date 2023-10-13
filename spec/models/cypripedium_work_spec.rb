# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CypripediumWork do
  let(:expected_attributes) do
    ["creator_id", "series", "issue_number", "abstract", "alternative_title",
     "bibliographic_citation", "corporate_name",
     "date_available", "extent", "has_part",
     "is_version_of", "has_version", "is_replaced_by",
     "replaces", "requires", "geographic_name",
     "table_of_contents", "temporal"]
  end

  it 'provides a list of locally added metadata' do
    expect(described_class.added_attributes).to match_array expected_attributes
  end
end
