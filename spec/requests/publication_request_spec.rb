# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'A Publication', type: :request do
  include_examples 'standard work requests for', Publication
end
