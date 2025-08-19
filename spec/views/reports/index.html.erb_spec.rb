# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "reports/index", :aggregate_failures, type: :view do
  let(:report) do
    [
      {
        'group' => 'Group',
        'id' => 'Id',
        'name' => 'Name',
        '2022' => '2022',
        '2023' => '2023',
        '2024' => '2024',
        '2025' => '2025',
        'total' => 'Totals'
      },
      {
        'group' => '',
        'id' => '',
        'name' => '',
        '2022' => '',
        '2023' => '',
        '2024' => '',
        '2025' => '',
        'total' => ''
      },
      {
        'group' => 'TOTALS',
        'id' => 'N/A',
        'name' => 'unique documents',
        '2022' => '25',
        '2023' => '45',
        '2024' => '52',
        '2025' => '18',
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
    expect(rendered).to have_selector('th.report-2024', text: '2024')
    expect(rendered).to have_selector('th.report-total', text: 'Total')
  end

  it 'renders data rows' do
    render
    expect(rendered).to have_selector('table tbody tr', count: 2)
    expect(rendered).to have_selector('td.report-group', text: 'TOTAL')
    expect(rendered).to have_selector('td.report-name', text: 'unique documents')
    expect(rendered).to have_selector('td.report-2025', text: '18')
  end
end
