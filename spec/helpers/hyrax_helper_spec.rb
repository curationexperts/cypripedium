# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HyraxHelper, type: :helper do
  describe '#available_translations' do
    it 'returns translations only for available languages' do
      expect(helper.available_translations.keys).to eq I18n.available_locales.map(&:to_s)
    end
  end
end
