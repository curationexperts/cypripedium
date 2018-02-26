class WorkZipsController < ApplicationController
  # Download the zip file that contains all the attached files for a work
  def download
    work_zip = WorkZip.latest(params[:work_id]).first
      raise ActiveRecord::RecordNotFound, "WorkZip not found: #{params[:work_id]}" unless work_zip && work_zip.file_path
    send_file(work_zip.file_path, type: "application/zip")
  end

  def create
    @work_zip = WorkZip.create!(work_id: params[:work_id])
    @work_zip.job_id = BuildWorkZipJob.perform_later(@work_zip.id).job_id
    @work_zip.save!
    redirect_back(fallback_location: root_path, notice: "A job has been queued to build the zip file. Please check back in a few minutes.")
  end
end
