# frozen_string_literal: true

require 'rails_helper'

describe 'User routes:', type: :routing do
  it 'a user cannot sign themselves up' do
    # You can't view the sign-up form:
    expect(get: '/users/signup').to route_to(
      controller: 'pages',
      action: 'error_404',
      path: 'users/signup'
    )
    # You can't create a new user account:
    expect(post: '/users').to route_to(
      controller: 'pages',
      action: 'error_404',
      path: 'users'
    )
  end
end
