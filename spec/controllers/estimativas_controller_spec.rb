require 'spec_helper'
require 'devise'

describe EstimativasController do
  include Helpers
  
  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  #describe "GET 'board'" do
    #it "returns http success" do
      #get 'board'
      #response.should be_success
    #end
  #end

  #describe "GET 'cartao'" do
    #it "returns http success" do
      #get 'cartao/'
      #response.should be_success
    #end
  #end

  before(:each) do
    sign_in admin_faz_login
  end
end
