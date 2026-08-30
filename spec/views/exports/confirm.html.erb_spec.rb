# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'exports/confirm', type: :view do
  let(:export) { build(:export, items: ['abc123', 'def456']) }

  before do
    assign(:export, export)
  end

  it 'renders the export confirmation form', :aggregate_failures do
    render
    expect(rendered).to have_field('export_filename', name: 'export[filename]')

    expect(rendered).to have_selector("form[@action='#{exports_path}'][@method='post'][@id='confirm_export_form']")
  end

  it 'renders the export items in hidden fields', :aggregate_failures do
    render
    expect(rendered).to have_field('export[items][]', type: :hidden, with: export.items.first)
    expect(rendered).to have_field('export[items][]', type: :hidden, count: export.items.count)
  end

  it 'has a cancel option' do
    render
    expect(rendered).to have_link('Cancel', href: hyrax.dashboard_works_path)
  end

  it 'displays a warning for duplicate exports', :aggregate_failures do
    existing_export = FactoryBot.create(:export, items: export.items, status: 'queued')

    render
    alert = Capybara.string(rendered).find('.alert-warning')

    expect(alert).to have_selector('li', text: /#{existing_export.id}.*bag.*queued/)
    expect(alert).to have_link('View existing exports', href: exports_path)
  end
end
