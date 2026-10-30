# frozen_string_literal: true

Rails.application.config.after_initialize do
  Rails.error.subscribe(ErrorLogSubscriber.new)
end
