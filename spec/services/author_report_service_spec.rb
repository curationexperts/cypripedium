# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AuthorReportService, :aggregate_failures do
  before do
    # Stub blacklight calls with sample data
    allow(Blacklight.default_index.connection)
      .to receive(:get).and_raise(RuntimeError, 'Unexpected Solr request')
    allow(Blacklight.default_index.connection)
      .to receive(:get).with('select', params: hash_including('q' => anything))
                       .and_return(JSON.load_file(file_fixture('author_report.json')))

    Creator.create!(id: 387, display_name: 'Karabarbounis, Loukas', group: 'consultant')
    Creator.create!(id: 429, display_name: 'Kuhn, Moritz', group: 'unassigned')
    Creator.create!(id: 562, display_name: 'Nicolini, Juan Pablo', group: 'staff')
    Creator.create!(id: 999, display_name: 'Keynes, John Maynard', group: 'consultant')
  end

  it 'returns an Array' do
    expect(described_class.run).to be_a_kind_of(Array)
  end

  it 'has expected headers in the first row' do
    report_data = described_class.run
    headers = report_data[0].values
    expect(headers).to include('Group', 'Id', 'Name', 'Total')
  end

  it 'includes aggregate counts' do
    report_data = described_class.run
    totals_row = report_data.find { |row| row['group'] == 'TOTAL' }
    expect(totals_row['2022']).to eq 25
    expect(totals_row['total']).to eq 140
  end

  it 'includes staff data' do
    report_data = described_class.run
    staff_row = report_data.find { |row| row['group'] == 'staff' }
    expect(staff_row['name']).to eq 'Nicolini, Juan Pablo'
    expect(staff_row['total']).to eq 11
  end

  it 'includes consultant data' do
    report_data = described_class.run
    consultant_row = report_data.find { |row| row['group'] == 'consultant' }
    expect(consultant_row['name']).to eq 'Karabarbounis, Loukas'
    expect(consultant_row['total']).to eq 5
  end

  it 'includes data for others' do
    report_data = described_class.run
    other_row = report_data.find { |row| row['group'] == 'unassigned' }
    expect(other_row['name']).to eq 'Kuhn, Moritz'
    expect(other_row['2024']).to eq 4
  end

  it 'leaves rows for unmatched creators blank' do
    report_data = described_class.run
    unmatched = report_data.find { |row| row['id'] == '999' }
    expect(unmatched['name']).to eq 'Keynes, John Maynard'
    expect(unmatched['total']).to be_blank
  end
end
