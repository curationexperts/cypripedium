# frozen_string_literal: true

class RequestShim < ActionDispatch::Request
  def host
    Rails.application.config.rdf_uri
  end
end
