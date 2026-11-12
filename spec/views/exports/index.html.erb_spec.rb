# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'exports/index', type: :view do
  let(:admin) { create(:admin) }

  let(:completed_export) { create(:export, user: admin, format: :bag, items: ['abc123'], status: :completed, visibility: :restricted) }
  let(:failed_export)    { create(:export, user: admin, format: :zip, items: ['def456'], status: :failed, message: 'unspecified error') }
  let(:queued_export)    { create(:export, user: admin, format: :zip, items: ['ghi789'], status: :queued, visibility: :authenticated) }
  let(:working_export)   { create(:export, user: admin, format: :bag, items: ['jkl012'], status: :working) }

  let(:exports) { [completed_export, failed_export, queued_export, working_export] }

  before do
    # Mimic an ActiveRecord relation ordered by id in descending order
    assign(:exports, exports.sort_by(&:id).reverse)
    allow(view).to receive(:main_app).and_return(main_app)
  end

  it 'renders a row for each export' do
    render
    expect(rendered).to have_selector('tbody tr', count: 4)
  end

  it 'includes a data-sort attribute on ids', :aggregate_failures do
    render
    # `data-sort` attributes should be in inverse order of the export order in the assigns
    expect(rendered).to have_selector("td.id[data-sort=0]", text: working_export.id)
    expect(rendered).to have_selector("td.id[data-sort=1]", text: queued_export.id)
    expect(rendered).to have_selector("td.id[data-sort=2]", text: failed_export.id)
    expect(rendered).to have_selector("td.id[data-sort=3]", text: completed_export.id)
  end

  it 'displays the export format' do
    render
    formats = Capybara.string(rendered).all('td.format').map(&:text)
    expect(formats).to eq ['bag', 'zip', 'zip', 'bag']
  end

  it 'displays the export status' do
    render
    statuses = Capybara.string(rendered).all('td.status').map(&:text)
    expect(statuses).to eq ['working', 'queued', 'failed', 'completed']
  end

  it 'has a download link for completed exports' do
    # We need an actual attachment for this test
    completed_export.export_file.attach(io: StringIO.new('zip'), filename: 'export.zip', content_type: 'application/zip')
    render
    row = Capybara.string(rendered).find("tr#export_#{completed_export.id}")
    expect(row).to have_link('export.zip', href: export_download_path(completed_export))
  end

  it 'displays an error message for exports without an export_file' do
    render
    row = Capybara.string(rendered).find("tr#export_#{failed_export.id}")
    expect(row).to have_selector('.output', text: 'Error: unspecified error')
  end

  context 'item count' do
    let(:failed_export)    { create(:export, items: ['d', 'e', 'f'], status: :failed) }
    let(:queued_export)    { create(:export, items: ['g', 'h'], status: :queued) }
    let(:working_export)   { create(:export, items: ['i', 'j', 'k', 'l'], status: :working) }

    it 'displays for all exports' do
      render
      items = Capybara.string(rendered).all('td.item_count').map(&:text).map(&:to_i)
      expect(items).to eq [4, 2, 3, 1]
    end
  end

  context 'exported count' do
    let(:completed_export) { create(:export, items: ['d', 'e', 'f'], status: :completed, exported_count: 2) }

    it 'displays when different from item count' do
      render
      row = Capybara.string(rendered).find("tr#export_#{completed_export.id}")
      expect(row).to have_selector('.item_count', text: '2 / 3', normalize_ws: true)
    end

    it 'does not display when equal to item count' do
      completed_export.update!(exported_count: completed_export.items.count)
      render
      row = Capybara.string(rendered).find("tr#export_#{completed_export.id}")
      expect(row).not_to have_selector('.exported_count')
    end

    it 'does not display when nil' do
      completed_export.update!(exported_count: nil)
      render
      row = Capybara.string(rendered).find("tr#export_#{completed_export.id}")
      expect(row).not_to have_selector('.exported_count')
    end
  end

  context 'error count' do
    it 'displays when positive and export_file is present' do
      completed_export.update!(error_count: 7)
      completed_export.export_file.attach(io: StringIO.new('zip'), filename: 'export.zip', content_type: 'application/zip')

      render
      row = Capybara.string(rendered).find("tr#export_#{completed_export.id}")
      expect(row).to have_selector('.error_count', text: '7 errors')
    end

    it 'is not displayed when zero and export_file is present', :aggregate_failures do
      completed_export.update!(error_count: 0)
      completed_export.export_file.attach(io: StringIO.new('zip'), filename: 'export.zip', content_type: 'application/zip')

      render
      row = Capybara.string(rendered).find("tr#export_#{completed_export.id}")
      expect(row).not_to have_selector('.error_count')
      expect(row).not_to have_content('0 errors')
    end

    it 'is not displayed when export_file is absent', :aggregate_failures do
      completed_export.update!(error_count: 47)

      render
      row = Capybara.string(rendered).find("tr#export_#{completed_export.id}")
      expect(row).not_to have_selector('.error_count')
      expect(row).not_to have_selector('td.output', text: '47')
    end
  end

  it 'includes an actions column header' do
    render
    expect(rendered).to have_selector('th.actions')
  end

  it 'shows a delete link for completed exports' do
    render
    row = Capybara.string(rendered).find("tr#export_#{completed_export.id}")
    expect(row).to have_button('Delete')
  end

  it 'shows a delete link for failed exports' do
    render
    row = Capybara.string(rendered).find("tr#export_#{failed_export.id}")
    expect(row).to have_button('Delete')
  end

  it 'does not show a delete link for queued exports' do
    render
    row = Capybara.string(rendered).find("tr#export_#{queued_export.id}")
    expect(row).not_to have_button('Delete')
  end

  it 'does not show a delete link for working exports' do
    render
    row = Capybara.string(rendered).find("tr#export_#{working_export.id}")
    expect(row).not_to have_button('Delete')
  end

  it 'delete link submits to the correct path' do
    render
    expect(rendered).to have_selector(
                          "form[action='#{main_app.export_path(completed_export)}'][method='post']"
                        )
  end

  it 'displays the export visibility' do
    render
    body = Capybara.string(rendered)
    expect(body.all('td.visibility').map(&:text))
      .to eq ['Public', 'FRBM', 'Public', 'Private']
  end
end
