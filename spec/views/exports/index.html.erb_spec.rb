# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'exports/index', type: :view do
  let(:admin) { create(:admin) }

  let(:completed_export) { create(:export, user: admin, format: :bag, items: ['abc123'], status: :completed) }
  let(:failed_export)    { create(:export, user: admin, format: :bag, items: ['def456'], status: :failed) }
  let(:queued_export)    { create(:export, user: admin, format: :bag, items: ['ghi789'], status: :queued) }
  let(:working_export)   { create(:export, user: admin, format: :bag, items: ['jkl012'], status: :working) }

  let(:exports) { [completed_export, failed_export, queued_export, working_export] }

  before do
    # Mimic an ActiveRecord relation orderd by id in descending order
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

  it 'has a download link for completed exports' do
    render
    within("tr#export_#{completed_export.id}") do
      expect(rendered).to have_link(href: download_export_path(completed_export))
    end
  end

  it 'includes an actions column header' do
    render
    expect(rendered).to have_selector('th.actions')
  end

  it 'shows a delete link for completed exports' do
    render
    within("tr#export_#{completed_export.id}") do
      expect(rendered).to have_button('Delete')
    end
  end

  it 'shows a delete link for failed exports' do
    render
    within("tr#export_#{failed_export.id}") do
      expect(rendered).to have_button('Delete')
    end
  end

  it 'does not show a delete link for queued exports' do
    render
    within("tr#export_#{queued_export.id}") do
      expect(rendered).not_to have_button('Delete')
    end
  end

  it 'does not show a delete link for working exports' do
    render
    within("tr#export_#{working_export.id}") do
      expect(rendered).not_to have_button('Delete')
    end
  end

  it 'delete link submits to the correct path' do
    render
    expect(rendered).to have_selector(
                          "form[action='#{main_app.export_path(completed_export)}'][method='post']"
                        )
  end
end
