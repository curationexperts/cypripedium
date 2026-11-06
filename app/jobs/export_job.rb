# frozen_string_literal: true

class ExportJob < ApplicationJob
  # Disable retries; if this job fails, it will be discarded immediately.
  sidekiq_options retry: false

  # Update the export status when a job is queued for the export.
  after_enqueue { |job| job.arguments.first.queued! }

  def perform(export)
    export.working!

    ExportPackager.package_items(export)

    export.completed!
    send_notification(export)

  rescue StandardError => e
    Rails.error.report(e, severity: :error, context: { export_id: export.id })
    export.update!(status: :failed, message: ErrorMessage.for(e))
    send_notification(export)
    raise e
  end

  private

  def send_notification(export)
    return if export.user.guest?

    notice = ExportNotification.new(export)
    User.system_user.send_message(export.user, notice.message, notice.subject)
  end
end
