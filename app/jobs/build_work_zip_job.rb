# frozen_string_literal: true

class BuildWorkZipJob < ApplicationJob

  queue_as :default

  # Find the WorkZip record and tell it to build a
  # zip file for its associated work.
  #
  # @param work_zip_id [String] The ID for the WorkZip record.
  def perform(work_zip_id)
    work_zip = WorkZip.find(work_zip_id)
    work_zip.create_zip
  end
end
