# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Requesting an unsupported locale', type: :request do
  let(:html) { Capybara.string(response.body) }

  it 'responds with 406 Not Acceptable' do
    get '/', params: { locale: 'pluto' }
    expect(response).to have_http_status(406)
  end

  it 'says the site is only available in English' do
    get '/', params: { locale: 'de' }
    expect(html).to have_css('#only-english')
  end
end
