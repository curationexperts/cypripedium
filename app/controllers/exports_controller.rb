# frozen_string_literal: true

class ExportsController < ApplicationController
  load_and_authorize_resource
  with_themed_layout 'dashboard'

  rescue_from CanCan::AccessDenied, with: :render404

  # GET /admin/exports
  def index
    add_breadcrumb t(:'hyrax.controls.home'), root_path
    add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
    add_breadcrumb t(:'dashboard.breadcrumbs.admin.exports')
    @exports = Export.all.order(created_at: :desc)
  end

  # DELETE /admin/exports/:id
  def destroy
    @export.destroy
    redirect_to exports_path, notice: 'Export deleted.'
  end

  # GET /exports/downloads/:id
  def download
    if @export.export_file.attached?
      redirect_to rails_blob_url(@export.export_file, disposition: 'attachment')
    else
      render404
    end
  end

  private

  def render404
    render file: Rails.public_path.join('404.html'), status: :not_found, layout: 'hyrax/1_column'
  end
end
