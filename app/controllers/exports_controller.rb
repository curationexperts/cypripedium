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
    @exports = @exports.reorder(id: :desc)
  end

  # POST /admin/exports/confirm
  def confirm
    @export = Export.new(export_params)
    redirect_to_works if @export.items.empty?
  end

  # POST /admin/exports
  def create
    @export.user = current_user
    return redirect_to_works if @export.items.empty?

    if @export.save
      ExportJob.perform_later(@export)
      redirect_to exports_path, notice: 'Export queued.'
    else
      render :confirm, status: :unprocessable_entity
    end
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

  def items
    ids = @export.items
    query = ids.map { |id| "id:#{RSolr.solr_escape(id)}" }.join(' OR ')
    results = Hyrax::SolrService.query(query,
                                       rows: ids.length,
                                       fl: 'id,title_tesim,has_model_ssim')
    indexed_results = results.index_by { |doc| doc['id'] }
    docs = ids.map { |id| SolrDocument.new(indexed_results.fetch(id, { 'id' => id })) }

    render partial: 'items', layout: false, locals: { export: @export, docs: docs }
  end

  private

  def export_params
    params.require(:export).permit(:filename, :format, items: [])
  end

  def render404
    render file: Rails.public_path.join('404.html'), status: :not_found, layout: 'hyrax/1_column'
  end

  def redirect_to_works
    redirect_back_or_to(
      hyrax.dashboard_works_path,
      allow_other_host: false,
      alert: 'Please select one or more items to export.'
    )
  end
end
