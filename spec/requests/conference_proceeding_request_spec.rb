# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'A Conference Proceeding', type: :request do
  include_examples 'standard work requests for', ConferenceProceeding
end
