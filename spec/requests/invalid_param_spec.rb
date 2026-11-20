# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Request parameter filtering', type: :request do
  it 'rejects malformed parameter names' do
    get '/?a[=1'
    expect(response).to have_http_status(:bad_request)
  end

  it 'leaves parentheses in the search field unencoded' do
    get '/catalog', params: { q: '(inflation OR wages)' }
    expect(Nokogiri::HTML(response.body).at_css('input#search-field-header')['value']).to eq '(inflation OR wages)'
  end

  describe 'inheritance' do
    it 'applies to the catalog controller' do
      get '/catalog?a[=1'
      expect(response).to have_http_status(:bad_request)
    end

    it 'applies to work controllers' do
      get '/concern/publications/new?a[=1'
      expect(response).to have_http_status(:bad_request)
    end

    it 'applies to unknown routes' do
      get '/fallthrough/route?a[=1'
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'logging' do
    let(:logger) { HomepageController.logger }
    before { allow(logger).to receive(:warn) }

    it 'records an invalid name' do
      get '/', params: { 'x"><b>' => '1' }
      expect(logger)
        .to have_received(:warn)
              .with('Rejected request: invalid parameter "x\"><b>"')
    end

    it 'records an invalid value' do
      get '/', params: { q: '<b>' }
      expect(logger)
        .to have_received(:warn)
              .with('Rejected request: invalid parameter "<b>"')
    end

    it 'truncates long names' do
      get '/', params: { 'x' * 255 => '1' }
      expect(logger)
        .to have_received(:warn)
              .with('Rejected request: invalid parameter "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx..."')
    end
  end
end
