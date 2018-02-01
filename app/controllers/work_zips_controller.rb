# Assumption: Since all works will have public
# visibility, this controller assumes that any user
# has the right to download a zip file of the work.
# In the future, if this assumption is no longer
# true, we'll need to add access controls to make
# sure the user is allowed to download the zip.

class WorkZipsController < ApplicationController
  # Download the zip file that contains all the attached files for a work
  def download
    work_zip = WorkZip.latest(params[:work_id]).first
    unless work_zip && work_zip.file_path
      raise ActiveRecord::RecordNotFound, "WorkZip not found: #{params[:work_id]}"
    end
    send_file(work_zip.file_path, type: "application/zip")
  end

  def create
    @work_zip = WorkZip.create!(work_id: params[:work_id])
    @work_zip.job_id = BuildWorkZipJob.perform_later(@work_zip.id).job_id
    @work_zip.save!
    redirect_back(fallback_location: root_path, notice: "A job has been queued to build the zip file. Please check back in a few minutes.")
  end
end
