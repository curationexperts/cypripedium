# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'

  protect_from_forgery with: :exception

  skip_after_action :discard_flash_if_xhr

  rescue_from I18n::InvalidLocale, with: :render_406

  def render_406
    params.delete('locale')
    render file: Rails.root.join('app', 'views', 'static', 'not_acceptable.html.erb'), status: :not_acceptable, layout: true
  end

  private

  def append_info_to_payload(payload)
    super
    payload[:request_id] = request.request_id
  end
end
