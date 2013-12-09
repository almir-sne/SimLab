require 'spec_helper'
require 'devise'

describe PagamentosController do
  include Helpers

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'periodos'" do
    it "returns http success" do
      get 'periodos', usuario_id: 1
      response.should be_success
    end
  end

  before(:each) do
    sign_in admin_faz_login
  end

end
