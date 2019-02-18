# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RequestShim do
  let(:request_shim) { described_class.new({}) }

  it 'returns the host' do
    expect(request_shim.host).to eq(Rails.application.config.rdf_uri)
  end
end
