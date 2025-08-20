# frozen_string_literal: true
class ReportsController < ApplicationController
  before_action :auth
  with_themed_layout 'dashboard'

  # GET /reports
  def index
    add_breadcrumb t(:'hyrax.controls.home'), root_path
    add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path if current_user&.admin?
    add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.reports'), '#'
    @start_date = 2022
    @report = AuthorReportService.run(start: @start_date)
  end

  private

  # Restrict to authorized admins
  def auth
    # Set a dummy user as a failsafe if no user is logged in
    current_user ||= User.new # rubocop:disable Lint/UselessAssignment
    authorize! action_name.to_sym, :reports
  end

  # Only allow a list of trusted parameters through.
  def safe_params
    params.require(:reports).permit(:display_name, { alternate_names: [] }, :repec, :viaf, :active_creator)
  end
end
