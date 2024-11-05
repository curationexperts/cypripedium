# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe "/concern/publications", type: :request, clean: true do
  let(:user) { FactoryBot.create(:admin) }

  before do
    Hyrax::AdminSetCreateService.find_or_create_default_admin_set
    login_as user
  end

  # As you add validations to Publication, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
      title: ["A test title"]
    }
  }

  let(:invalid_attributes) {
    { title: "Title not in an array" }
  }

  describe "GET /index" do
    it "renders a successful response" do
      Publication.create! valid_attributes
      # There is no index just for publications, the catalog is basically
      # the index for the application
      get "/catalog"
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      publication = Publication.create! valid_attributes
      get hyrax_publication_url(publication)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_hyrax_publication_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "render a successful response" do
      publication = Publication.create! valid_attributes
      get edit_hyrax_publication_url(publication)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Publication" do
        expect {
          post hyrax_publications_url, params: { publication: valid_attributes }
        }.to change(Publication, :count).by(1)
      end

      it "redirects to the created publication" do
        post hyrax_publications_url, params: { publication: valid_attributes }
        expect(response).to redirect_to(hyrax_publication_url(Publication.last) + "?locale=en")
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { title: ["A brand new title"] }
      }

      it "updates the requested publication" do
        publication = Publication.create! valid_attributes
        patch hyrax_publication_url(publication), params: { publication: new_attributes }
        publication.reload
        expect(publication.title).to eq ["A brand new title"]
      end

      it "redirects to the publication" do
        publication = Publication.create! valid_attributes
        patch hyrax_publication_url(publication), params: { publication: new_attributes }
        publication.reload
        expect(response).to redirect_to(hyrax_publication_url(publication) + "?locale=en")
      end
    end
  end
end
