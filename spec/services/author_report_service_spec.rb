# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AuthorReportService do
  before do
    allow(Blacklight.default_index.connection)
      .to receive(:get).with('select', params: hash_including('q'))
                       .and_return(file_fixture('author_report.json').read)

  end
  it 'returns JSON' do
    expect(described_class.run(start: '2023')).to be_a_kind_of(Hash)
  end

  it 'accepts a start date' do
    pending 'full implementation'
    expect(described_class.run(start: '2023')).to include '2023-01-05'
  end

  it 'does not include data before the sart date' do
    pending 'full implementation'
    expect(described_class.run(start: '2023-06-01')).not_to include '2023-01-05'
  end

  it 'includes aggregate counts' do
    debugger
    report_data = described_class.run(start: '2023-06-01')
    expect(report_data.keys).to include()
  end
end