# frozen_string_literal: true

class ExportJob < ApplicationJob
  # Disable retries; if this job fails, it will be discarded immediately.
  sidekiq_options retry: false

  # Update the export status when a job is queued for the export.
  after_enqueue { |job| job.arguments.first.queued! }

  def perform(export)
    export.working!

    item_count = ExportPackager.package_items(export)

    export.completed!
    notify_success(export, item_count)

  rescue StandardError => e
    export.update!(status: :failed, message: e.message.presence || e.class.name)
    notify_failure(export)
    raise e
  end

  private

  def notify_success(export, item_count)
    return if export.user.guest?
    User.system_user.send_message(export.user, success_message(export, item_count), 'Export completed')
  end

  def notify_failure(export)
    return if export.user.guest?
    User.system_user.send_message(export.user, failure_message(export), 'Export failed')
  end

  # rubocop:disable Rails/OutputSafety
  def success_message(export, item_count)
    <<~MSG.html_safe
      <div>
        Your export (#{export.id}) containing #{item_count} #{'item'.pluralize(item_count)}#{' '}
        is available for download at
        <a href="#{Rails.application.routes.url_helpers.export_download_path(export)}">
          #{export.base_filename}.zip
        </a>
      </div>
    MSG
  end

  def failure_message(export)
    <<~MSG.html_safe
      <div>
        Your export (#{export.id}) failed with the following error:
        <pre>#{ERB::Util.html_escape(export.message)}</pre>
      </div>
    MSG
  end
  # rubocop:enable Rails/OutputSafety
end
