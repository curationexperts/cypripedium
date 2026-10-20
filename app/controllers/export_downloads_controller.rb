# frozen_string_literal: true

# Streams export archives through an authenticated session.
# ActiveStorage::Streaming includes ActionController::Live, which changes how
# every action in a controller runs, so it is isolated here rather than in
# ExportsController.
class ExportDownloadsController < ApplicationController
  include ActiveStorage::Streaming

  load_and_authorize_resource class: 'Export', instance_name: :export

  rescue_from CanCan::AccessDenied, with: :render404

  # GET /exports/downloads/:id
  def download
    if @export.export_file.attached?
      send_blob_stream(@export.export_file, disposition: 'attachment')
    else
      render404
    end
  end

  private

  def render404
    render file: Rails.public_path.join('404.html'), status: :not_found, layout: 'hyrax/1_column'
  end
end
