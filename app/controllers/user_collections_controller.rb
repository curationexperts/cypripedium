# frozen_string_literal: true

class UserCollectionsController < ApplicationController
  def create
    message = 'You have successfully registered to receive email notifications of new publications in the following collections:'
    status = '200'
    begin
      new_params = user_collections_params
      @user_collections_obj = UserCollections.find_or_initialize_by(email: new_params['email'])
      @user_collections_obj.collections = new_params['collections']
      @user_collections_obj.save!
    rescue => exc
      message = exc.message
      status = 'error'
    end
    render json: { user_collections: @user_collections_obj.to_json, message: message, status: status }
  end

  def show
    status = '200'
    message = ''
    begin
      new_params = user_collections_params
      raise StandardError, "The email cannot be empty!" if new_params['email'].blank?
      @user_collections_obj = UserCollections.find_by(email: new_params['email'])
      @user_collections_obj = "" if @user_collections_obj.blank?
    rescue => exc
      message = exc.message
      status = 'error'
    end
    render json: { user_collections: @user_collections_obj.to_json, message: message, status: status }
  end

  def destroy
    begin
      status = '200'
      new_params = user_collections_params
      raise StandardError, "The email cannot be empty!" if new_params['email'].blank?
      @user_collections_obj = UserCollections.find_by(email: new_params['email'])
      raise StandardError, "User with email '" + new_params['email'] + "' has no subscrptions!" if @user_collections_obj.blank?
      json = @user_collections_obj.to_json
      @user_collections_obj.destroy
      message = "You (" + new_params['email'] + ") have unsubscribed to the follow collections:"
    rescue exc
      message = exc.message
      status = 'error'
    end
    render json: { user_collections: json, message: message, status: status }
  end

  private

  def user_collections_params
    params.permit(:email, { collections: [] })
  end
end
