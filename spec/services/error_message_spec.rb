# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ErrorMessage do
  describe '.for' do
    it 'returns short messages unchanged' do
      exception = StandardError.new('A short error message')

      expect(described_class.for(exception)).to eq 'A short error message'
    end

    it 'returns the class name when there is no message' do
      exception = StandardError.new('')

      expect(described_class.for(exception)).to eq 'StandardError'
    end

    it 'returns only the first line of multi-line messages' do
      exception = StandardError.new("The first line of a multi-line error message\nAnd another line")

      expect(described_class.for(exception)).to eq 'The first line of a multi-line error message'
    end

    it 'truncates long messages' do
      exception = StandardError.new(
        'ERR_SHIVER_ME_TIMBERS: Prow scuttle parrel provost Sail ho shrouds spirits boom mizzenmast yardarm. ' \
          'Pinnace holystone mizzenmast quarter nipperkin grog yardarm  furl starboard grog black jack gangway.'
      )

      expect(described_class.for(exception))
        .to eq 'ERR_SHIVER_ME_TIMBERS: Prow scuttle parrel provost Sail ho shrouds ' \
                 'spirits boom mizzenmast yardarm. Pinnace holystone m…'
    end
  end
end
