# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ParamFilter do
  controller(ApplicationController) do
    def index
      head :ok
    end
  end

  # Test to flag if someone enables filtering in Blacklight
  # if so, we may want to adjust param name filtering.
  it 'assumes Blacklight filtering is disabled' do
    expect(CatalogController.blacklight_config.filter_search_state_fields).to be false
  end

  it 'accepts every Blacklight search state field name' do
    search_state_params = CatalogController.blacklight_config.search_state_fields
                             .flat_map { |field| field.is_a?(Hash) ? field.keys : field }
                             .to_h { |name| [name.to_s, '1'] }

    expect(controller.send(:invalid_param, search_state_params)).to be_nil
  end

  it 'accepts requests with valid param names' do
    get :index, params: { f: { creator_sim: ['Brown'] }, 'facet.sort': 'index', utf8: 'x' }
    expect(response).to have_http_status(:ok)
  end

  it 'rejects invalid param names' do
    get :index, params: { 'DummyParameter"><DIV STYLE="width:expression(qssX140648910946464Y0_1Z=7)">' => '1' }
    expect(response).to have_http_status(:bad_request)
  end

  it 'accepts properly nested names' do
    get :index, params: { page: '1', a: [{ title: '1', ok: '2' }], q: 'x' }
    expect(response).to have_http_status(:ok)
  end

  it 'rejects bad names nested in the parameters' do
    get :index, params: { page: '1', a: [{ 'x"><b>' => '1', ok: '2' }], q: 'x' }
    expect(response).to have_http_status(:bad_request)
  end

  it 'rejects long (>40) param names' do
    get :index, params: { 'x' * 41 => '1' }
    expect(response).to have_http_status(:bad_request)
  end

  it 'accepts single dotted names' do
    get :index, params: { 'facet.page' => '3' }
    expect(response).to have_http_status(:ok)
  end

  it 'rejects multiply dotted names' do
    get :index, params: { 'a.b.c' => '1' }
    expect(response).to have_http_status(:bad_request)
  end

  it 'accepts negated facet names' do
    get :index, params: { f: { '-creator_sim': ['Brown'] } }
    expect(response).to have_http_status(:ok)
  end

  it 'rejects tag-like values' do
    get :index, params: { f: { series_sim: ['"><DIV STYLE="width:expression(qssX140648910946464Y0_1Z=7)">'] } }
    expect(response).to have_http_status(:bad_request)
  end

  it 'accepts quotes, apostrophes, and angle brackets in values' do
    get :index, params: { q: %q("monetary policy" O'Brien & Kehoe x < 5 and GDP > 2%) }
    expect(response).to have_http_status(:ok)
  end

  it 'accepts paranthesis in facet values' do
    get :index, params: { f: { series_sim: ['Quarterly review (Federal Reserve Bank of Minneapolis. Research Department)'] } }
    expect(response).to have_http_status(:ok)
  end
end
