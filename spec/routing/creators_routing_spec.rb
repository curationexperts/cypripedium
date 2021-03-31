require "rails_helper"

RSpec.describe CreatorsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/creators").to route_to("creators#index")
    end

    it "routes to #new" do
      expect(get: "/creators/new").to route_to("creators#new")
    end

    it "routes to #show" do
      expect(get: "/creators/1").to route_to("creators#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/creators/1/edit").to route_to("creators#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/creators").to route_to("creators#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/creators/1").to route_to("creators#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/creators/1").to route_to("creators#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/creators/1").to route_to("creators#destroy", id: "1")
    end
  end
end
