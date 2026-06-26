# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'exports/index', type: :view do
  let(:admin) { create(:admin) }

  let(:completed_export) { create(:export, user: admin, format: :bag, items: ['abc123'], status: :completed) }
  let(:failed_export)    { create(:export, user: admin, format: :bag, items: ['def456'], status: :failed) }
  let(:queued_export)    { create(:export, user: admin, format: :bag, items: ['ghi789'], status: :queued) }
  let(:working_export)   { create(:export, user: admin, format: :bag, items: ['jkl012'], status: :working) }

  before do
    assign(:exports, [completed_export, failed_export, queued_export, working_export])
    allow(view).to receive(:main_app).and_return(main_app)
  end

  it 'renders a row for each export' do
    render
    expect(rendered).to have_selector('tbody tr', count: 4)
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
