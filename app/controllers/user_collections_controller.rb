# frozen_string_literal: true

class UserCollectionsController < ApplicationController
  load_and_authorize_resource
  with_themed_layout 'dashboard'

  def index
    add_breadcrumb t(:'hyrax.controls.home'), root_path
    add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path if current_user&.admin?
    add_breadcrumb t(:'hyrax.user_collections.index.manage_user_collections'), '#' if current_user&.admin?
    @user_collections = UserCollection.all.order(:email)
  end

  def create
    message = 'You have successfully registered to receive email notifications of new publications in the following collections:'
    status = '200'
    begin
      new_params = user_collections_params
      @user_collection = UserCollection.find_or_initialize_by(email: new_params['email'])
      @user_collection.collections = new_params['collections']
      @user_collection.save!
    rescue => exc
      message = exc.message
      status = 'error'
    end
    render json: { user_collections: @user_collection.to_json, message: message, status: status }
  end

  def show
    status = '200'
    message = ''
    begin
      new_params = user_collections_params
      raise StandardError, "The email cannot be empty!" if new_params['email'].blank?
      set_user_collection
      @user_collection = "" if @user_collection.blank?
    rescue => exc
      message = exc.message
      status = 'error'
    end
    render json: { user_collections: @user_collection.to_json, message: message, status: status }
  end

  def destroy
    begin
      status = '200'
      new_params = user_collections_params
      raise StandardError, "The email cannot be empty!" if new_params['email'].blank?
      @user_collection = set_user_collection
      raise StandardError, "User with email '" + new_params['email'] + "' has no subscrptions!" if @user_collection.blank?
      json = @user_collection.to_json
      @user_collection.destroy
      message = "You (" + new_params['email'] + ") have unsubscribed to the following collections:"
    rescue exc
      message = exc.message
      status = 'error'
    end
    render json: { user_collections: json, message: message, status: status }
  end

  # GET /user_collections/1/edit
  def edit
    add_breadcrumb t(:'hyrax.controls.home'), root_path
    add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path if current_user&.admin?
    add_breadcrumb t(:'hyrax.user_collections.index.manage_user_collections'), user_collections_path if current_user&.admin?
    add_breadcrumb "Edit User Email Registrations", '#'
    set_user_collection
  end

  # # PATCH/PUT /user_collections/1
  # # PATCH/PUT /user_collections/1.json
  # def update
  #   set_user_collection
  #   respond_to do |format|
  #     if @user_collection.update(user_collections_params)
  #       format.html { redirect_to '/user_collections' }
  #     else
  #       format.html { render :edit }
  #     end
  #   end
  # end

  private

  def set_user_collection
    @user_collection = UserCollection.find(params[:id]) if params[:id].present?
    @user_collection = UserCollection.find_by(email: params['email']) if @user_collection.blank?
  end

  def user_collections_params
    params.permit(:email, { collections: [] })
  end
end
