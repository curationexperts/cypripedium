# frozen_string_literal: true

class BagController < ApplicationController
  skip_after_action :discard_flash_if_xhr

  def download
    send_file("#{Rails.application.config.bag_path}/#{bag_params}.zip", type: 'application/zip', disposition: 'attachment')
  end

  def create
    BagJob.perform_later(work_ids: create_params, user: current_user)
    redirect_to hyrax.notifications_path, alert: "The items you selected are being bagged. Please refresh this page for updates."
  end

  private

    def create_params
      params.require(:work_ids)
    end

    def bag_params
      params.require(:file_name)
    end
end
