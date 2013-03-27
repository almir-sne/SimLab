require 'spec_helper'
# add it to  test js  ", :js => true"
describe "Projetos" do
  it "cria novo projeto" do
    visit new_projeto_path
    fill_in "Name",  :with => "teste_cria_novo_projeto"
    click_button "Create Projeto"
    page.should have_content("Projeto was successfully created.")
    page.should have_content("teste_cria_novo_projeto")
  end

  it "verifica criacao" do
    user = FactoryGirl.build :projeto, name: "Atlas"
    assert_equal user.name, "Atlas"
  end
end
