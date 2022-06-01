require "rails_helper"

RSpec.describe CorporatesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/corporates").to route_to("corporates#index")
    end

    it "routes to #new" do
      expect(get: "/corporates/new").to route_to("corporates#new")
    end

    it "routes to #show" do
      expect(get: "/corporates/1").to route_to("corporates#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/corporates/1/edit").to route_to("corporates#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/corporates").to route_to("corporates#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/corporates/1").to route_to("corporates#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/corporates/1").to route_to("corporates#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/corporates/1").to route_to("corporates#destroy", id: "1")
    end
  end
end
