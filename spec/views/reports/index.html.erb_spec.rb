# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "reports/index", :aggregate_failures, type: :view do
  let(:report) do
    [
      {
        'group' => 'Group',
        'id' => 'Id',
        'name' => 'Name',
        '2022-01-01T00:00:00Z' => '2022',
        '2023-01-01T00:00:00Z' => '2023',
        '2024-01-01T00:00:00Z' => '2024',
        '2025-01-01T00:00:00Z' => '2025',
        'total' => 'Totals'
      },
      {
        'group' => '',
        'id' => '',
        'name' => '',
        '2022-01-01T00:00:00Z' => '',
        '2023-01-01T00:00:00Z' => '',
        '2024-01-01T00:00:00Z' => '',
        '2025-01-01T00:00:00Z' => '',
        'total-01-01T00:00:00Z' => ''
      },
      {
        'group' => 'TOTALS',
        'id' => 'N/A',
        'name' => 'unique documents',
        '2022-01-01T00:00:00Z' => '25',
        '2023-01-01T00:00:00Z' => '45',
        '2024-01-01T00:00:00Z' => '52',
        '2025-01-01T00:00:00Z' => '18',
        'total' => '140'
      }
    ]
  end

  before do
    assign(:report, report)
  end

  it 'renders a header row' do
    render
    expect(rendered).to have_selector('table thead tr', count: 1)
    expect(rendered).to have_selector('th.report-group', text: 'Group')
    # there should be a column for the starting year
    expect(rendered).to have_selector('th.report-2022-01-01t00-00-00z', text: '2022')
    # there should be a column for each year between the starting year and now
    expect(rendered).to have_selector('th.report-2024-01-01t00-00-00z', text: '2024')
    # the report should not inlcude dates before the start date
    expect(rendered).not_to have_selector('th.report-2021-01-01t00-00-00-00z')
    expect(rendered).to have_selector('th.report-total', text: 'Total')
  end

  it 'renders data rows' do
    render
    expect(rendered).to have_selector('table tbody tr', count: 2)
    expect(rendered).to have_selector('td.report-group', text: 'TOTAL')
    expect(rendered).to have_selector('td.report-name', text: 'unique documents')
    expect(rendered).to have_selector('td.report-2025-01-01t00-00-00z', text: '18')
  end

  it 'has a CSV download link' do
    render
    expect(rendered).to have_link(id: 'reports-download', href: '/reports?format=csv')
  end

  describe 'each creator name' do
    let(:creator) { FactoryBot.create(:creator) }
    before {
      report << {
        'group' => creator.group,
        'id' => creator.id,
        'name' => creator.display_name,
        '2023-01-01t00-00-00z' => 4,
        '2025-01-01t00-00-00z' => 6,
        'total' => '10'
      }
    }

    it 'has a link to documents by that author' do
      render
      expect(rendered).to have_link(creator.display_name, href: /\/catalog.*&range%5Bdate_created_iti%5D%5Bbegin%5D=2022/)
    end
  end
end
