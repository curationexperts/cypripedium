# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Qa do
  let(:table_name_prefix) { described_class.table_name_prefix }
  it 'has a table prefix set' do
    expect(table_name_prefix).to eq('qa_')
  end
end
