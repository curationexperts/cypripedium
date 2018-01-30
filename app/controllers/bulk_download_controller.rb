# coding: utf-8
class BulkDownloadController < ApplicationController
  def download
    send_data(BulkDownloadJob.perform_now(params[:id]), filename: download_file_name, type: 'application/zip')
  end

  private

    def download_file_name
      doc = SolrDocument.find(params[:id])
      title = Shellwords.escape(doc.title[0][0..30].gsub(/\s+/, ""))
      date = Time.now.in_time_zone.strftime('%Y-%m-%d')
      "#{title}_#{date}.zip"
    end
end
