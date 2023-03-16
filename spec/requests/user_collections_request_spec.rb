# frozen_string_literal: true
require 'rails_helper'
require 'json'

include Warden::Test::Helpers

RSpec.describe "/user_collection", type: :request, clean: true do
  SUCCESS_MESSAGE = 'You have successfully registered to receive email notifications of new publications in the following collections:'
  ERROR_MESSAGE = "Validation failed: Email is invalid"
  DELETE_MESSAGE = "You (test@test.com) have unsubscribed to the following collections:"
  REDIRECT_MESSASGE = "<html><body>You are being <a href=\"http://www.example.com/users/sign_in?locale=en\">redirected</a>.</body></html>"

  let(:user) { FactoryBot.create(:admin) }
  let(:valid_attributes) {
    { email: "test@test.com", collections: ["collection1", "collection2"] }
  }
  let(:invalid_attributes) {
    { email: "test@test", collections: [] }
  }

  describe "GET /index" do
    it "Unauthorized request to retrieve all user_collections" do
      UserCollection.create! valid_attributes
      get user_collections_url, params: valid_attributes
      expect(response.body.to_s).to eq REDIRECT_MESSASGE
      response.status = 302
    end
  end

  describe "GET /index" do
    it "Authorized request to retrieve all user_collections" do
      login_as user
      UserCollection.create! valid_attributes
      get user_collections_url, params: valid_attributes
      expect(response.body).to include('<td class="display_name">test@test.com</td>'), count: 1
      expect(response.body).to include('data-remote="true" rel="nofollow" data-method="delete" href="/user_collection?email=test%40test.com&amp;locale=en">Unsubscribe')
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "create a new user_collection" do
        post user_collection_url, params: valid_attributes
        response_body_obj = JSON.parse(response.body)
        expect(response_body_obj['status']).to eq '200'
        expect(response_body_obj['message']).to eq SUCCESS_MESSAGE
        user_collection_string = response_body_obj['user_collections']
        user_collection = JSON.parse(user_collection_string)
        expect(user_collection['id']).present?
        expect(user_collection['email']).to eq "test@test.com"
        expect(user_collection['collections']).to eq ["collection1", "collection2"]
      end
    end

    context "with invalid parameters" do
      it "create a new user_collection" do
        post user_collection_url, params: invalid_attributes
        response_body_obj = JSON.parse(response.body)
        expect(response_body_obj['status']).to eq 'error'
        expect(response_body_obj['message']).to eq ERROR_MESSAGE
        user_collection_string = response_body_obj['user_collections']
        user_collection = JSON.parse(user_collection_string)
        expect(user_collection['id']).blank?
        expect(user_collection['email']).to eq "test@test"
        expect(user_collection['collections']).blank?
      end
    end

    describe "GET /show" do
      it "renders a successful json response" do
        user_collection = UserCollection.create! valid_attributes
        get user_collection_url, params: valid_attributes
        response_body_obj = JSON.parse(response.body)
        expect(response_body_obj['status']).to eq '200'
        expect(user_collection['id']).present?
        expect(user_collection['email']).to eq "test@test.com"
        expect(user_collection['collections']).to eq ["collection1", "collection2"]
      end
    end

    describe "DELETE /create" do
      context "with valid parameters" do
        it "delete a user_collection" do
          UserCollection.create! valid_attributes
          delete user_collection_url, params: valid_attributes
          response_body_obj = JSON.parse(response.body)
          puts response_body_obj.to_s
          expect(response_body_obj['message']).to eq DELETE_MESSAGE
        end
      end
    end
  end
end
