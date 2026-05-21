# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

describe 'Qualys patches' do
  # NOTE: these tests use the test string used by Qualys.
  # The test string is somewhat long and sometimes obscures the goal of individual tests.
  # However, for now, we've decided to keep the longer form to make comparing the resutls to Qalys reports eaiser.
  context 'for "150084 unencoded character injection"' do
    it 'replaces potentially dangerous characters in ATOM feeds' do
      visit "/catalog.atom?q=discovery%22%3E%3CDIV%20STYLE%3D%22width%3Aexpression(qssX140136678030192Y4_1Z%3D7)%22%3E"
      expect(page.find('title').text).to eq('discovery%22%3E%3CDIV%20STYLE%3D%22width%3Aexpression%28qssX140136678030192Y4_1Z%3D7%29%22%3E - Research Database Search Results')
    end

    it 'does not reflect invalid query strings' do
      visit '/catalog/bad_unique_id?&q=*&DummyField=discovery%22%3E%3CDIV%20STYLE%3D%22width%3Aexpression(qssX140136678030192Y4_1Z%3D7)%22%3E&search_field=all_fields'
      expect(page).to have_no_field('DummyField', type: 'hidden')
    end

    it 'encodes parenthesis in the per_page parameter' do
      visit '/catalog?q=&per_page="><DIV STYLE="width:expression(qssX140544040006928Y1_1Z-7)">'
      expect(page).to have_field('per_page', type: 'hidden', with: '%22%3E%3CDIV%20STYLE%3D%22width%3Aexpression%28qssX140544040006928Y1_1Z-7%29%22%3E')
    end

    it 'encodes parenthesis in arbitrary parameters' do
      visit '/catalog?q=&foo="><DIV STYLE="width:expression(qssX140544040006928Y1_1Z-7)">'
      expect(page).to have_field('foo', type: 'hidden', with: '%22%3E%3CDIV%20STYLE%3D%22width%3Aexpression%28qssX140544040006928Y1_1Z-7%29%22%3E')
    end

    it 'does not modify existing encodings' do
      encoded = '%22%3E%3CDIV%20STYLE%3D%22width%3Aexpression%28qssX140043725525456Y3_1Z%3D7%29%22%3E'
      visit "/catalog?q=&foo=#{encoded}"
      expect(page).to have_field('foo', type: 'hidden', with: encoded)
    end
  end
end
