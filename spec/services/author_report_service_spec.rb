# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AuthorReportService, :aggregate_failures do
  before do
    # Stub blacklight calls with sample data
    allow(Blacklight.default_index.connection)
      .to receive(:get).and_raise(RuntimeError, 'Unexpected Solr request')
    allow(Blacklight.default_index.connection)
      .to receive(:get).with('select', params: hash_including('facet.range' => '{!tag=r1}date_uploaded_dtsi'))
                       .and_return(JSON.load_file(file_fixture('author_report.json')))
    # NOTE: author_report.json was generated with the following query
    # http://localhost:8993/solr/cypripedium/select?fq=date_created_iti:[2022%20TO%20*]&fq=date_uploaded_dtsi:[2022-01-01T00:00:00Z%20TO%20*]&fq=creator_id_ssim%3A(562+OR+429+OR+387)&rows=0&facet=true&facet.limit=-1&facet.mincount=0&facet.range=%7B!tag=r1%7Ddate_uploaded_dtsi&facet.range.start=2022-01-01T00:00:00Z&facet.range.end=2026-01-01T00:00:00Z&facet.range.gap=%2B3MONTH&facet.pivot=%7B!range=r1%7Dcreator_id_ssim

    Creator.create!(id: 387, display_name: 'Karabarbounis, Loukas', group: 'consultant')
    Creator.create!(id: 429, display_name: 'Kuhn, Moritz', group: 'unassigned')
    Creator.create!(id: 562, display_name: 'Nicolini, Juan Pablo', group: 'staff')
    Creator.create!(id: 999, display_name: 'Keynes, John Maynard', group: 'consultant')
  end

  it 'returns an Array' do
    expect(described_class.run).to be_a_kind_of(Array)
  end

  it 'sends a valid Solr query' do
    allow(Blacklight.default_index.connection).to receive(:get).and_call_original
    expect { described_class.new }.not_to raise_exception
  end

  it 'has expected headers in the first row' do
    report_data = described_class.run
    headers = report_data[0].values
    expect(headers).to include('Group', 'ID', 'Name', 'Total')
  end

  it 'includes aggregate counts' do
    report_data = described_class.run
    totals_row = report_data.find { |row| row['group'] == 'TOTAL' }
    expect(totals_row['2024-04-01T00:00:00Z']).to eq 4
    expect(totals_row['total']).to eq 16
  end

  it 'includes staff data' do
    report_data = described_class.run
    staff_row = report_data.find { |row| row['group'] == 'staff' }
    expect(staff_row['name']).to eq 'Nicolini, Juan Pablo'
    expect(staff_row['total']).to eq 8
  end

  it 'includes consultant data' do
    report_data = described_class.run
    consultant_row = report_data.find { |row| row['group'] == 'consultant' }
    expect(consultant_row['name']).to eq 'Karabarbounis, Loukas'
    expect(consultant_row['total']).to eq 3
  end

  it 'includes data for others' do
    report_data = described_class.run
    other_row = report_data.find { |row| row['group'] == 'unassigned' }
    expect(other_row['name']).to eq 'Kuhn, Moritz'
    expect(other_row['2024-01-01T00:00:00Z']).to eq 2
  end

  it 'leaves rows for unmatched creators blank' do
    report_data = described_class.run
    unmatched = report_data.find { |row| row['id'] == '999' }
    expect(unmatched['name']).to eq 'Keynes, John Maynard'
    expect(unmatched['total']).to be_blank
  end

  it 'passes the start date to Solr' do
    allow(Blacklight.default_index.connection)
      .to receive(:get).with('select', params: hash_including('facet.range' => '{!tag=r1}date_uploaded_dtsi'))
    described_class.new(start: '1998-01-01')
    expect(Blacklight.default_index.connection)
      .to have_received(:get).with('select', params: hash_including('fq' => array_including('date_uploaded_dtsi:[1998-01-01T00:00:00Z TO *]')))
  end

  describe '#start_date' do
    before do
      allow(Blacklight.default_index.connection).to receive(:get).and_return({})
    end

    it 'is a valid Solr DateTime string' do
      service = described_class.new
      expect(service.start_date).to match(/\d{4}-\d{2}-\d{2}T00:00:00Z/)
    end

    it 'converts a string date' do
      service = described_class.new(start: '07 Nov 2005')
      expect(service.start_date).to eq '2005-11-07T00:00:00Z'
    end

    it 'accepts a Time object' do
      service = described_class.new(start: Time.zone.parse('2009-04-19T07:15:00Z'))
      expect(service.start_date).to eq '2009-04-19T00:00:00Z'
    end

    it 'defaults to 3 years ago for unparseable dates' do
      travel_to('2017-05-23T17:46:18Z')
      service = described_class.new(start: 'A few years ago')
      expect(service.start_date).to eq '2014-01-01T00:00:00Z'
    end
  end

  describe '#period' do
    before do
      allow(Blacklight.default_index.connection).to receive(:get).and_return({})
    end

    it 'defaults to :yearly' do
      service = described_class.new
      expect(service.period).to eq :yearly
    end

    it 'accepts strings' do
      service = described_class.new(period: 'monthly')
      expect(service.period).to eq :monthly
    end

    it 'accepts symbols' do
      service = described_class.new(period: :quarterly)
      expect(service.period).to eq :quarterly
    end

    it 'defaults to :yearly for unexpected input' do
      service = described_class.new(period: 'fortnightly')
      expect(service.period).to eq :yearly
    end
  end
end
