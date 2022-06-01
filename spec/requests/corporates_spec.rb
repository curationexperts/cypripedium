# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers
# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/corporates", type: :request, clean: true do
  let(:user) { FactoryBot.create(:admin) }
  before do
    login_as user
  end
  # Corporate. As you add validations to Corporate, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    { corporate_name: "A corporate name", corporate_state: "A state", corporate_city: "A city" }
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  describe "GET /index" do
    it "renders a successful response" do
      Corporate.create! valid_attributes
      get corporates_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      corporate = Corporate.create! valid_attributes
      get corporate_url(corporate)
      expect(response).to be_successful
    end

    it "renders a successful json response" do
      corporate = Corporate.create! valid_attributes
      get corporate_url(corporate), params: { format: :json }
      expect(response).to be_successful
      expect(response.content_type).to eq "application/json"
      expect(response.body).not_to be_empty
      expect(response.content_length).to be > 0
      response_values = JSON.parse(response.body)
      expect(response_values["corporate_name"]).to eq "A corporate name"
      expect(response_values["corporate_state"]).to eq "A state"
      expect(response_values["corporate_city"]).to eq "A city"
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_corporate_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "render a successful response" do
      corporate = Corporate.create! valid_attributes
      get edit_corporate_url(corporate)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Corporate" do
        expect {
          post corporates_url, params: { corporate: valid_attributes }
        }.to change(Corporate, :count).by(1)
      end

      it "redirects to the created corporate" do
        post corporates_url, params: { corporate: valid_attributes }
        expect(response).to redirect_to(corporate_url(Corporate.last) + "?locale=en")
      end
    end

    context "with invalid parameters" do
      it "does not create a new Corporate" do
        expect {
          post corporates_url, params: { corporate: invalid_attributes }
        }.to change(Corporate, :count).by(0)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post corporates_url, params: { corporate: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { corporate_name: "A new corporate name", corporate_state: "A new state", corporate_city: "A new city" }
      }

      it "updates the requested corporate" do
        corporate = Corporate.create! valid_attributes
        patch corporate_url(corporate), params: { corporate: new_attributes }
        corporate.reload
        expect(corporate.corporate_name).to be "A new corporate name"
      end

      it "redirects to the corporate" do
        corporate = Corporate.create! valid_attributes
        patch corporate_url(corporate), params: { corporate: new_attributes }
        corporate.reload
        expect(response).to redirect_to(corporate_url(corporate) + "?locale=en")
      end
    end

    context "with invalid parameters" do
      it "renders a successful response (i.e. to display the 'edit' template)" do
        corporate = Corporate.create! valid_attributes
        patch corporate_url(corporate), params: { corporate: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end
end
