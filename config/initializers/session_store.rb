# frozen_string_literal: true
Cypripedium::Application.config.session_store(
  :cookie_store,
  key: '_cypripedium_session',
  secure: Rails.env.production?
)
