class BulkDownloadJob < ApplicationJob
  queue_as :default

  def perform(work_id)
    BulkDownload.new(work_id).read_zip
  end
end
