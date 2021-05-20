# frozen_string_literal: true

class BagController < ApplicationController
  before_action :set_locale
  ALLOWED_EXTENSIONS = ['zip', 'tar'].freeze

  def download
    send_file("#{Rails.application.config.bag_path}/#{bag_params}.#{format_params}", type: "application/#{format_params}", disposition: 'attachment')
  end

  def create
    BagJob.perform_later(work_ids: create_params, user: current_user, compression: compression_params)
    redirect_to hyrax.notifications_path, alert: "The items you selected are being bagged. Please refresh this page for updates."
  end

  private

  def create_params
    params.require(:work_ids)
  end

  def bag_params
    File.basename(params.require(:file_name))
  end

  def compression_params
    return unless params[:compression]
    allowed = ALLOWED_EXTENSIONS.map { |file_ext| params[:compression].include?(file_ext) }
    return 'zip' unless allowed.include?(true)
    params[:compression]
  end

  def format_params
    return unless params[:format]
    allowed = ALLOWED_EXTENSIONS.map { |file_ext| params[:format].include?(file_ext) }
    return 'zip' unless allowed.include?(true)
    params[:format]
  end
end
