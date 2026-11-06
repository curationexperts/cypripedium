# frozen_string_literal: true

# Builds human-readable status messages for exports.
# Designed primarily for use in notifications.
class ExportNotification
  # @param export [Export] the export to describe
  def initialize(export)
    @export = export
  end

  # Subject line suitable for notifications, e.g. "Export 25 completed successfully"
  #
  # @return [String] the export ID and status
  # @return [nil] if the export is not completed or failed
  def subject
    return unless @export.completed? || @export.failed?

    "Export #{@export.id} #{@export.status}"
  end

  # Humanized status message suitable for notifications in HTML format
  # Includes the status, a summary of the export, any exception message,
  # and a link to the exported archive when available.
  #
  # @return [ActiveSupport::SafeBuffer] HTML-safe markup
  # @return [nil] if the export is not completed or failed
  def message
    return unless @export.completed? || @export.failed?

    helpers.tag.div do
      helpers.safe_join([
        subject_sentence,
        summary_sentence,
        exception_sentence,
        download_sentence
      ].compact, "\n")
    end
  end

  private

  def download_sentence
    return unless @export.export_file.attached?

    helpers.safe_join([download_span, csv_errors_span].compact, "\n")
  end

  def download_span
    download_link = helpers.link_to(@export.export_file.filename, routes.export_download_path(@export, locale: nil))
    helpers.tag.span(class: 'download') do
      helpers.safe_join(['The exported archive can be downloaded at ', download_link, '.'])
    end
  end

  def csv_errors_span
    return unless @export.error_count.positive?

    helpers.tag.span(class: 'csv-errors') do
      is = @export.error_count == 1 ? ' is' : 's are'
      "#{@export.error_count} error#{is} listed in the \"metadata.csv\" file in the archive."
    end
  end

  def exception_sentence
    return unless @export.message.present? # rubocop:disable Rails/Blank

    helpers.tag.span(class: 'exception') do
      "The error message was: \"#{@export.message}\"."
    end
  end

  def helpers
    ActionController::Base.helpers
  end

  def routes
    Rails.application.routes.url_helpers
  end

  def subject_sentence
    helpers.tag.span(subject + '.', class: 'subject')
  end

  def summary_sentence
    return unless @export.exported_count.present? # rubocop:disable Rails/Blank

    helpers.tag.span(class: 'summary') do
      [summary_because, summary_action, summary_adverb].compact_blank.join(' ').capitalize + '.'
    end
  end

  def summary_because
    return if @export.exported_count == @export.items.count # nothing omitted

    if @export.error_count.positive?
      'due to visibility restrictions or errors,'
    else
      'due to visibility restrictions,'
    end
  end

  def summary_action
    return 'no items were exported' if @export.exported_count.zero?
    return 'some items were not exported' if @export.exported_count < @export.items.count
    'all items were exported'
  end

  def summary_adverb
    return unless @export.error_count.zero? && @export.exported_count == @export.items.count

    'successfully'
  end
end
