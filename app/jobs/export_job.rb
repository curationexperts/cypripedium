# frozen_string_literal: true

class ExportJob < ApplicationJob
  after_enqueue { |job| job.arguments.first.queued! }

  def perform(export)
    @export = export
    @export.working!

    @item_count = ExportPackager.package_itmes(@export)

    @export.completed!
    notify(success: true)

  rescue StandardError => e
    @export.update!(status: :failed, message: e.message)
    notify(success: false)
  end

  private

  def notify(success:)
    return if @export.user.guest?
    subject = success ? 'Export completed' : 'Export failed'
    message = success ? success_message : failure_message
    User.system_user.send_message(@export.user, message, subject)
  end

  # rubocop:disable Rails/OutputSafety
  def success_message
    <<~MSG.html_safe
      <div>
        Your export (#{@export.id}) containing #{@item_count} #{'item'.pluralize(@item_count)}#{' '}
        is available for download at
        <a href="#{Rails.application.routes.url_helpers.export_download_path(@export)}">
          #{@export.base_filename}.zip
        </a>
      </div>
    MSG
  end

  def failure_message
    <<~MSG.html_safe
      <div>
        Your export (#{@export.id}) failed with the following error:
        <pre>#{ERB::Util.html_escape(@export.message)}</pre>
      </div>
    MSG
  end
  # rubocop:enable Rails/OutputSafety
end
