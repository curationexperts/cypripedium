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

  rescue_from I18n::InvalidLocale, with: :render_406

  def render_406 # rubocop:disable Naming/VariableNumber
    params.delete('locale')
    render template: 'pages/not_acceptable', status: :not_acceptable
  end
end
