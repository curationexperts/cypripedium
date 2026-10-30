# frozen_string_literal: true

# Writes handled Rails.error reports to Rails.logger so they reach the environment logs.
# Unhandled reports are skipped; Rails and Sidekiq already log uncaught exceptions.
class ErrorLogSubscriber
  # Rails.error severities mapped to Logger levels
  LEVELS = { error: :error, warning: :warn, info: :info }.freeze

  def report(error, handled:, severity:, context:, source:)
    return unless handled

    Rails.logger.public_send(
      LEVELS.fetch(severity),
      message: error.message,
      payload: context.merge(source: source),
      exception: error
    )
  end
end
