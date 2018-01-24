# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::Actors::ConferenceProceedingActor do
  let(:actor) { described_class }
  it 'is a ConferenceProceedingActor class' do
    expect(actor.name).to eq('Hyrax::Actors::ConferenceProceedingActor')
  end
end
