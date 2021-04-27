# frozen_string_literal: true
class CreatorsController < ApplicationController
  include Hydra::Controller::ControllerBehavior
  before_action :set_creator, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /creators
  # GET /creators.json
  def index
    @creators = Creator.all.order(:display_name)
  end

  def active_creators
    @active_creators = Creator.where { active != false }
  end

  def active_creators
    @active_creators = Creator.where { active != false }
  end

  # GET /creators/1
  # GET /creators/1.json
  def show; end

  # GET /creators/new
  def new
    @creator = Creator.new
  end

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
        format.html { render :new }
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
        format.html { render :edit }
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
    new_params["alternate_names"].reject!(&:blank?)
    new_params
  end

  # Only allow a list of trusted parameters through.
  def safe_params
    params.require(:creator).permit(:display_name, { alternate_names: [] }, :repec, :viaf, :active_creator)
  end
end
