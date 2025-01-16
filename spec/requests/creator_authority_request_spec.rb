# frozen_string_literal: true

require 'rails_helper'

describe 'Creator authority', type: :request, clean: true do
  before do
    creator_array = [
      { "id": "http://id.loc.gov/authorities/names/no2003126550", "label": "Cagetti, Marco", "active": true },
      { "id": "http://id.loc.gov/authorities/names/no2003126550", "label": "Cagetti, NotThisOne", "active": false }, # NOTE: This one should be inactive
      { "id": "https://ideas.repec.org/f/pca1299.html", "label": "Cai, Zhifeng", "active": true },
      { "id": "https://ideas.repec.org/e/pca150.html", "label": "Calsamiglia, Caterina", "active": true },
      { "id": "https://ideas.repec.org/f/pca694.html", "label": "Calvo, Guillermo A.", "active": true }
    ]
    creator_array.each do |creator|
      Creator.create!(
        display_name: creator[:label],
        active_creator: creator[:active]
      )
    end
  end

  describe "GET /authorities/search/creator_authority" do
    it "returns http success and only active creators" do
      get "/authorities/search/creator_authority?q=Ca"
      expect(response).to have_http_status(:success)
      expect(response.content_type).to match "application/json"
      json_body = JSON.parse(response.body)
      expect(json_body.count).to eq 4
      expect(json_body.first["label"]).to eq "Cagetti, Marco"
    end
    it "returns fewer responses for a longer string" do
      get "/authorities/search/creator_authority?q=Cal"
      expect(response).to have_http_status(:success)
      json_body = JSON.parse(response.body)
      expect(json_body.count).to eq 2
      expect(json_body.first["label"]).to eq "Calsamiglia, Caterina"
    end
  end

  describe "GET /authorities/show/creator_authority" do
    before do
      allow(Rails.application.config)
        .to receive(:rdf_uri)
              .and_return('http://localhost:3000')
    end
    it "can return an authority entry based on identifier" do
      expect(Rails.application.config.rdf_uri).to eq 'http://localhost:3000'
      creator_id = Creator.first.id
      get "/authorities/show/creator_authority/#{creator_id}"
      expect(response).to have_http_status(:success)
      expect(response.body).not_to be_empty
      expect(response.content_length).to be > 3
      json_body = JSON.parse(response.body)
      expect(json_body["id"]).to eq "http://localhost:3000/authorities/show/creator_authority/#{creator_id}"
      expect(json_body["label"]).to eq "Cagetti, Marco"
    end

    it "can fail gracefully when an id doesn't exist" do
      get "/authorities/show/creator_authority/9999"
      expect(response).to have_http_status(:success)
      expect(response.body).to eq "null"
    end
  end

  describe "GET /authorities/terms/creator_authority" do
    it "can show all the creators in a list, including inactive ones" do
      get "/authorities/terms/creator_authority"
      expect(response).to have_http_status(:success)
      json_body = JSON.parse(response.body)
      expect(json_body.count).to eq 5
      expect(json_body.first["label"]).to eq "Cagetti, Marco"
    end
  end
end
