require "spec_helper"

describe ReunioesController do
  describe "routing" do

    it "routes to #index" do
      get("/reunioes").should route_to("reunioes#index")
    end

    it "routes to #new" do
      get("/reunioes/new").should route_to("reunioes#new")
    end

    it "routes to #show" do
      get("/reunioes/1").should route_to("reunioes#show", :id => "1")
    end

    it "routes to #edit" do
      get("/reunioes/1/edit").should route_to("reunioes#edit", :id => "1")
    end

    it "routes to #create" do
      post("/reunioes").should route_to("reunioes#create")
    end

    it "routes to #update" do
      put("/reunioes/1").should route_to("reunioes#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/reunioes/1").should route_to("reunioes#destroy", :id => "1")
    end

  end
end
