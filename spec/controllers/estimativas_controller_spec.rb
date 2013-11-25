require 'spec_helper'

describe EstimativasController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'board'" do
    it "returns http success" do
      get 'board'
      response.should be_success
    end
  end

  describe "GET 'cartao'" do
    it "returns http success" do
      get 'cartao'
      response.should be_success
    end
  end

end
