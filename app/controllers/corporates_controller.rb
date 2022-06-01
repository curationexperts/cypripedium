# frozen_string_literal: true
class CorporatesController < ApplicationController
  include Hydra::Controller::ControllerBehavior
  load_and_authorize_resource
  before_action :set_corporate, only: [:show, :edit, :update, :destroy]
  before_action :pick_theme
  before_action :set_locale

  def pick_theme
    if current_user&.admin?
      CorporatesController.with_themed_layout 'dashboard'
    else
      CorporatesController.with_themed_layout '1_column'
    end
  end

  # GET /corporates
  # GET /corporates.json
  def index
    add_breadcrumb t(:'hyrax.controls.home'), root_path
    add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path if current_user&.admin?
    add_breadcrumb t(:'hyrax.corporates.index.manage_corporates'), '#'
    @corporates = Corporate.all.order(:corporate_name)
  end

  # GET /corporates/1
  # GET /corporates/1.json
  def show
    add_breadcrumb t(:'hyrax.controls.home'), root_path
    add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path if current_user&.admin?
    add_breadcrumb t(:'hyrax.corporates.index.manage_corporates'), '#'
  end

  # GET /corporates/new
  def new
    @corporate = Corporate.new
  end

  # GET /corporates/1/edit
  def edit
    add_breadcrumb t(:'hyrax.controls.home'), root_path
    add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path if current_user&.admin?
    add_breadcrumb t(:'hyrax.corporates.index.manage_corporates'), corporates_path
    add_breadcrumb "Edit Corporate", '#'
  end

  # POST /corporates
  # POST /corporates.json
  def create
    @corporate = Corporate.new(corporate_params)

    respond_to do |format|
      if @corporate.save
        format.html { redirect_to @corporate, notice: 'Corporate was successfully created.' }
        format.json { render :show, status: :created, location: @corporate }
      else
        format.html { render :new }
        format.json { render json: @corporate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /corporates/1
  # PATCH/PUT /corporates/1.json
  def update
    respond_to do |format|
      if @corporate.update(corporate_params)
        format.html { redirect_to @corporate, notice: 'Corporate was successfully updated.' }
        format.json { render :show, status: :ok, location: @corporate }
      else
        format.html { render :edit }
        format.json { render json: @corporate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /corporates/1
  # DELETE /corporates/1.json
  def destroy
    @corporate.destroy
    respond_to do |format|
      format.html { redirect_to corporates_url, notice: 'Corporate was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_corporate
    @corporate = Corporate.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def corporate_params
    params.require(:corporate).permit(:corporate_name, :corporate_state, :corporate_city)
  end
end
