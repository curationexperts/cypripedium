# frozen_string_literal: true
require 'rails_helper'
RSpec.describe Cypripedium::Metadata do
  let(:local_attributes) do
    ["abstract", "alternative_title", "bibliographic_citation",
     "corporate_name", "creator_id", "date_available", "extent",
     "geographic_name", "has_part", "has_version",
     "is_replaced_by", "is_version_of", "issue_number",
     "replaces", "requires", "series",
     "table_of_contents", "temporal"]
  end

  describe '.attribute_names' do
    it 'includes local properties' do
      expect(described_class.attribute_names).to include('issue_number', 'series')
    end

    it 'excludes Hyrax metadata properties' do
      expect(described_class.attribute_names).not_to include('import_url', 'relative_path')
    end
  end
end
