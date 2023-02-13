# frozen_string_literal: true

class UserCollectionsController < ApplicationController
  def create
    message = 'You have successfully registered for email notifications of new publications!'
    begin
      new_params = user_collections_params
      @user_collections = UserCollections.find_or_initialize_by(new_params)
      @user_collections.save!
    rescue => exc
      message = exc.message
    end
    render :json => { :user_collections => @user_collections, :message => message }
  end

  private

  def user_collections_params
    params.permit(:email, { collections: [] })
  end
end
