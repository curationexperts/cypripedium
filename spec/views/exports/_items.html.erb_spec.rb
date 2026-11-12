# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'exports/_items', type: :view do
  let(:export) { create(:export, items: docs.map(&:id), status: :queued) }
  let(:docs) do
    [
      SolrDocument.new('id' => 'abc123', 'title_tesim' => ['Test Publication'], 'has_model_ssim' => ['Publication']),
      SolrDocument.new('id' => 'missing123')
    ]
  end

  before { render partial: 'exports/items', locals: { export: export, docs: docs } }

  it 'displays the export status' do
    expect(rendered).to have_selector('.status', text: 'Queued')
  end

  it 'displays the update time' do
    expect(rendered).to have_selector('.updated_at', text: export.updated_at.strftime('%Y-%m-%d %H:%M:%S'))
  end

  it 'displays the export format' do
    expect(rendered).to have_selector('.format', text: 'zip')
  end

  it 'displays the export visibility' do
    expect(rendered).to have_selector('.visibility', text: 'Public')
  end

  describe 'counts' do
    context 'when the exported_count is nil' do
      it 'displays the item count alone', :aggregate_failures do
        expect(rendered).to have_selector('.item_count', text: '2')
        expect(rendered).not_to have_selector('.exported_count')
      end
    end

    context 'when the exported_count is present' do
      let(:export) { create(:export, items: docs.map(&:id), exported_count: 1) }
      it 'displays exported and item counts', :aggregate_failures do
        expect(rendered).to have_selector('.item_count', text: '2')
        expect(rendered).to have_selector('.exported_count', text: '1')
      end
    end

    context 'when the exported_count and item_count are equal' do
      let(:export) { create(:export, items: docs.map(&:id), exported_count: 2) }
      it 'suppresses the exported count', :aggregate_failures do
        expect(rendered).to have_selector('.item_count', text: '2')
        expect(rendered).not_to have_selector('.exported_count')
      end
    end
  end

  describe 'export_file' do
    context 'when absent' do
      let(:export) { create(:export, items: docs.map(&:id), status: :failed, error_count: 7) }
      it 'omits download link and error count' do
        expect(rendered).not_to have_selector('.download-link')
        expect(rendered).not_to have_selector('.error_count')
      end
    end

    context 'when present' do
      let(:export) do
        create(:export, items: docs.map(&:id)).tap do |export|
          export.export_file.attach(io: StringIO.new('zip'), filename: 'export.zip', content_type: 'application/zip')
        end
      end

      it 'displays download link', :aggregate_failures do
        expect(rendered).to have_link(class: 'download-link', href: export_download_path(export))
        expect(rendered).not_to have_selector('.error_count')
      end

      context 'with errors' do
        let(:export) do
          create(:export, items: docs.map(&:id), status: :completed, error_count: 5).tap do |export|
            export.export_file.attach(io: StringIO.new('zip'), filename: 'export.zip', content_type: 'application/zip')
          end
        end

        it 'displays error count', :aggregate_failures do
          expect(rendered).to have_link(class: 'download-link', href: export_download_path(export))
          expect(rendered).to have_selector('.error_count', text: '5')
        end
      end
    end
  end

  it 'displays the item id as a link' do
    expect(rendered).to have_link('abc123',
                                  href: "/concern/publications/abc123")
  end

  it 'displays the item title' do
    expect(rendered).to have_selector('.title', text: 'Test Publication')
  end

  it 'renders a row for each item' do
    expect(rendered).to have_selector('.export-item', count: 2)
  end

  context 'when the item is missing' do
    it 'displays the id without a link', :aggregate_failures do
      expect(rendered).to have_selector('.id', text: 'missing123')
      expect(rendered).not_to have_link(href: /missing123/)
    end

    it 'displays "Item not available" in italics' do
      expect(rendered).to have_selector('em', text: 'Item not available')
    end
  end

  describe 'message' do
    context 'when present' do
      let(:export) { create(:export, items: docs.map(&:id), message: 'This is a message') }
      it 'displays the message' do
        expect(rendered).to have_selector('#export-message', text: 'This is a message')
      end
    end

    context 'when absent' do
      let(:export) { create(:export, items: docs.map(&:id)) }
      it 'does not display the message' do
        expect(rendered).not_to have_selector('#export-message')
      end
    end
  end
end
