# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::Actors::ImageActor do
  let(:actor) { described_class }
  it 'is a ImageActor class' do
    expect(actor.name).to eq('Hyrax::Actors::ImageActor')
  end
end
