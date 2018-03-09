# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::Actors::DatasetActor do
  let(:actor) { described_class }
  it 'is a DatasetActor class' do
    expect(actor.name).to eq('Hyrax::Actors::DatasetActor')
  end
end
