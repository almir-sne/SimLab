require 'spec_helper'

feature "Projetos" do
  scenario "cria novo projeto" do
    visit new_projeto_path
    fill_in "Name",  :with => "teste_cria_novo_projeto"
    click_button I18n.t("helpers.submit.create", :model => I18n.t("activerecord.models.project"))
    page.should have_content(I18n.t(".sucess", :model => "Projeto"))
    page.should have_content("teste_cria_novo_projeto")
  end
end
