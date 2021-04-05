# frozen_string_literal: true

require 'rails_helper'

describe 'Creator authority', type: :request do
  before do
    creators_auth = Qa::LocalAuthority.find_or_create_by(name: 'creators')
    creator_array = [
      {"id":"http://id.loc.gov/authorities/names/no2003126550","label":"Cagetti, Marco"},
      {"id":"https://ideas.repec.org/f/pca1299.html","label":"Cai, Zhifeng"},
      {"id":"https://ideas.repec.org/e/pca150.html","label":"Calsamiglia, Caterina"},
      {"id":"https://ideas.repec.org/f/pca694.html","label":"Calvo, Guillermo A."},
      {"id":"https://ideas.repec.org/f/pca371.html","label":"Camargo, Braz"},
      {"id":"https://ideas.repec.org/e/pca89.html","label":"Campbell, Jeffrey R."},
      {"id":"https://ideas.repec.org/e/pca50.html","label":"Canova, Fabio"},
      {"id":"https://ideas.repec.org/e/pca77.html","label":"Caplin, Andrew"},
      {"id":"https://ideas.repec.org/f/pca1029.html","label":"Carapella, Francesca"},
      {"id":"https://ideas.repec.org/e/pca42.html","label":"Carlstrom, Charles T., 1960-"},
      {"id":"https://ideas.repec.org/f/pca205.html","label":"Caselli, Francesco, 1966-"},
      {"id":"https://ideas.repec.org/e/pca73.html","label":"Caucutt, Elizabeth M. (Elizabeth Miriam)"},
      {"id":"https://ideas.repec.org/f/pca963.html","label":"Cavalcanti, Ricardo de Oliveira"}
    ]
    creator_array.each do |creator|
      Qa::LocalAuthorityEntry.create!(
        uri: creator[:id],
        local_authority: creators_auth,
        label: creator[:label]
      )
    end
  end

  describe "GET /authorities/search/local/creators" do
    it "returns http success" do
      get "/authorities/search/local/creators?q=Ca"
      json_body = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq "application/json"
      expect(json_body.count).to eq 13
      expect(json_body.first["label"]).to eq "Cagetti, Marco"
      expect(json_body.first["id"]).to eq "http://id.loc.gov/authorities/names/no2003126550"
    end
    it "returns fewer responses for a longer string" do
      get "/authorities/search/local/creators?q=Cam"
      json_body = JSON.parse(response.body)
      expect(json_body.count).to eq 2
      expect(json_body.first["label"]).to eq "Camargo, Braz"
    end

    it "can return an authority entry based on uri" do
      # uri_identifier = Qa::LocalAuthorityEntry.first.uri
      # expect(uri_identifier).to eq "http://id.loc.gov/authorities/names/no2003126550"
      # uri_escaped = CGI.escape(uri_identifier)
      # puts uri_escaped

      get "/authorities/show/local/creators/cheese"
      expect(response).to have_http_status(:success)
    end
  end

end
