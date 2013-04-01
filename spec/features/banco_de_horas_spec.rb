require 'spec_helper'

describe "Banco de horas" do
  it "cria novo banco de horas" do
    visit root_path
    fill_in "Login", :with =>@admin.email
    fill_in "Senha", :with =>@admin.password
    click_button "Entrar"
#    save_and_open_page
    visit new_banco_de_hora_path
  end

  before(:all) do
    @admin = FactoryGirl.create(:usuario)
  end

end
