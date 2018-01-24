# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::Actors::DataSetActor do
  let(:actor) { described_class }
  it 'is a DataSetActor class' do
    expect(actor.name).to eq('Hyrax::Actors::DataSetActor')
  end
end
