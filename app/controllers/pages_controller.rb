# frozen_string_literal: true

class PagesController < ApplicationController
  def error_404 # rubocop:disable Naming/VariableNumber
    # Clear params so we don't reflect any injection attacks
    params.slice!(:controller, :action, :path)
    flash[:alert] = 'The page you are looking for does not exist.'
    render file: Rails.public_path.join('404.html'), status: :not_found
  end
end
