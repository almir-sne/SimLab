require 'spec_helper'

describe AtividadesController do
  include Helpers

  describe "GET 'estatiticas'" do
    it "returns http success" do
      get 'estatiticas'
      response.should be_success
    end
  end

  describe "GET 'ver_atividades'" do
    it "returns http success" do
      get 'ver_atividades'
      response.should be_success
    end
  end

  describe "GET 'atualizar_cartoes'" do
    it "returns http success" do
      get 'atualizar_cartoes'
      response.should be_success
    end
  end

  before(:each) do
	  admin_faz_login
	end
end
