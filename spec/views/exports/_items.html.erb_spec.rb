# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'exports/_items', type: :view do
  let(:export) { create(:export, items: docs.map(&:id)) }
  let(:docs) do
    [
      SolrDocument.new('id' => 'abc123', 'title_tesim' => ['Test Publication'], 'has_model_ssim' => ['Publication']),
      SolrDocument.new('id' => 'missing123')
    ]
  end

  before { render partial: 'exports/items', locals: { export: export, docs: docs } }

  it 'displays the item id as a link' do
    expect(rendered).to have_link('abc123',
                                  href: "/concern/publications/abc123")
  end

  it 'displays the item title' do
    expect(rendered).to include('Test Publication')
  end

  it 'renders a row for each item' do
    expect(rendered).to have_selector('li', count: 2)
  end

  context 'when the item is missing' do
    it 'displays the id without a link', :aggregate_failures do
      expect(rendered).to include('missing123')
      expect(rendered).not_to have_link(href: /missing123/)
    end

    it 'displays "Item not available" in italics' do
      expect(rendered).to have_selector('em', text: 'Item not available')
    end
  end
end
