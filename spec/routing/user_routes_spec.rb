# frozen_string_literal: true

require 'rails_helper'

describe 'User routes:', type: :routing do
  it 'a user cannot sign himself up' do
    # You can't view the sign-up form:
    expect(get: '/users/signup').not_to be_routable
    # You can't create a new user account:
    expect(post: '/users').not_to be_routable
  end
end
