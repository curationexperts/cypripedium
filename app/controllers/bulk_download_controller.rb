class BulkDownloadController < ApplicationController
  def download
    bulk_download = BulkDownload.new(params[:id])
    send_data(bulk_download.read_zip, filename: "#{params[:id]}.zip", type: 'application/zip')
  end
end
