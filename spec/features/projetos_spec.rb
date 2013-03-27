require 'spec_helper'
# add it to  test js  ", :js => true"
describe "Projetos" do
  it "nao consegue criar novo projeto" do
    visit new_projeto_path
    fill_in "Name",  :with => "teste_cria_novo_projeto"
    #save_and_open_page # debug
    click_button "Criar Projeto"
    page.should have_content("prohibited this projeto from being saved")
  end

  it "verifica criacao" do
    user = FactoryGirl.build :projeto, name: "Atlas"
    assert_equal user.name, "Atlas"
  end
end
