module WorkZipsHelper
  def display_work_zip_controls(work_zip)
    if work_zip.file_path && File.exist?(work_zip.file_path)
      link_to_download_zip(work_zip.work_id)
    elsif work_zip.status == :unavailable
      button_to_create_new_zip(work_zip.work_id)
    elsif work_zip.status != :completed
      content_tag(:p, "The job is not finished yet.  Please check back in a few minutes.  Current job status: #{work_zip.status}")
    else
      button_to_create_new_zip(work_zip.work_id)
    end
  end

  def link_to_download_zip(work_id)
    link_to 'Download the zip file', main_app.download_zip_path(work_id)
  end

  def button_to_create_new_zip(work_id)
    button_to 'Create the Zip', main_app.create_zip_path(work_id)
  end
end
