# frozen_string_literal: true

class BagController < ApplicationController
  def download
    send_file("#{Rails.application.config.bag_path}/#{bag_params}.tar", type: 'application/x-tar', disposition: 'attachment')
  end

  def create
    BagJob.perform_later(work_ids: create_params)
  end

  private

    def create_params
      params.require(:work_ids)
    end

    def bag_params
      params.require(:file_name)
    end
end
