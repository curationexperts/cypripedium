# frozen_string_literal: true

module WorkZipsHelper
  def display_work_zip_controls(work_zip)
    if work_zip.file_path && File.exist?(work_zip.file_path)
      link_to 'Download the zip file', main_app.download_zip_path(work_zip.work_id), download: true
    elsif work_zip.status == :unavailable
      button_to 'Create the Zip', main_app.create_zip_path(work_zip.work_id)
    elsif work_zip.status != :completed
      tag.p("The job is not finished yet.  Please check back in a few minutes.  Current job status: #{work_zip.status}")
    else
      button_to 'Create the Zip', main_app.create_zip_path(work_zip.work_id)
    end
  end
end
