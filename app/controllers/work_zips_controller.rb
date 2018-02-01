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
end
