# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'A Dataset', type: :request do
  include_examples 'standard work requests for', Dataset
end
