# frozen_string_literal: true
class CreatorsController < ApplicationController
  include Hydra::Controller::ControllerBehavior
  load_and_authorize_resource
  before_action :set_creator, only: [:show, :edit, :update, :destroy]
  before_action :set_breadcrumbs
  with_themed_layout :pick_layout

  def pick_layout
    current_user&.admin? ? 'hyrax/dashboard' : 'hyrax/1_column'
  end

  # GET /creators
  # GET /creators.json
  def index
    @creators = Creator.all.order(:display_name)
  end

  # GET /creators/1
  # GET /creators/1.json
  def show; end

  # GET /creators/new
  def new; end

  # GET /creators/1/edit
  def edit; end

  # POST /creators
  # POST /creators.json
  def create
    @creator = Creator.new(creator_params)

    respond_to do |format|
      if @creator.save
        format.html { redirect_to @creator, notice: 'Creator was successfully created.' }
        format.json { render :show, status: :created, location: @creator }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @creator.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /creators/1
  # PATCH/PUT /creators/1.json
  def update
    respond_to do |format|
      if @creator.update(creator_params)
        format.html { redirect_to @creator, notice: 'Creator was successfully updated.' }
        format.json { render :show, status: :ok, location: @creator }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @creator.errors, status: :unprocessable_entity }
      end
    end
  end

  # TODO: implement disable/inactivate.

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_creator
    @creator = Creator.find(params[:id])
  end

  # remove empty strings from alternate_names array
  def creator_params
    new_params = safe_params
    new_params["alternate_names"]&.compact_blank!
    new_params
  end

  # Only allow a list of trusted parameters through.
  def safe_params
    params.require(:creator).permit(:display_name, { alternate_names: [] }, :group, :repec, :viaf, :active_creator)
  end

  # Set breadcrumbs - e.g. / Home / Dashboard / Manage Creators / ...
  def set_breadcrumbs
    add_breadcrumb t(:'hyrax.controls.home'), root_path
    add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path if current_user&.admin?
    add_breadcrumb t(:'hyrax.creators.index.manage_creators'), creators_path
    add_breadcrumb @creator&.display_name if [:show, :edit, :update].include?(action_name.to_sym)
    add_breadcrumb "New Creator" if [:new, :create].include?(action_name.to_sym)
  end
end
