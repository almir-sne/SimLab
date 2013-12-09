require 'spec_helper'
require 'devise'

describe AtividadesController do
  include Helpers

 # describe "GET 'ver_atividades'" do
 #   it "returns http success" do
 #     get 'ver_atividades'
 #     response.should be_success
 #   end
 # end
  
  #describe "GET 'atualizar_cartoes'" do
    #it "returns http success" do
      #get 'atualizar_cartoes'
      #response.should be_success
    #end
  #end

  before(:each) do
    sign_in admin_faz_login
	end
end
