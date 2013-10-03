require 'spec_helper'

describe CartoesController do

  describe "GET 'estatisticas'" do
    it "returns http success" do
      get 'estatisticas'
      response.should be_success
    end
  end

end
