# frozen_string_literal: true

class BagController < ApplicationController
  def download
    send_file Rails.application.config.bag_path + bag_params
  end

  private

    def bag_params
      params.require(:file_name)
    end
end
