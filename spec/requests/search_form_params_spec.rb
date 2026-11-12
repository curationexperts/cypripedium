# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Blacklight::SearchForm' do
  let(:html) { Capybara.string(response.body) }

  it 'does not echo unknown parameters' do
    get '/', params: { 'foo"><b>' => '1' }
    expect(html).not_to have_css('input[name="foo"]')
    hidden_inputs = html.all('input[type="hidden"]', visible: :all).pluck(:name)
    expect(hidden_inputs).not_to include(a_string_starting_with('foo'))
  end

  it 'does not error on unknown parameters' do
    get '/', params: { 'foo"><b>' => '1' }
    expect(response).to be_successful
  end
end
