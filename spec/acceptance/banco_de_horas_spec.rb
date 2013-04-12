require 'spec_helper'

feature BancoDeHora do
  include Helpers

  scenario "deveria poder ser criado" do
    visit new_banco_de_hora_path
    click_button I18n.t("helpers.submit.create", :model => "Banco de hora")
    page.should have_content(I18n.t("banco_de_horas.create.sucess"))
  end

  scenario "deveria poder ser editado" do
    visit edit_banco_de_hora_path(@banco)
    click_button I18n.t("helpers.submit.update", :model => "Banco de hora")
    page.should have_content(I18n.t("banco_de_horas.update.sucess"))
  end

  scenario "deveria der visualizvel" do
    visit banco_de_hora_path(@banco)
    page.should have_content("Horas:")
  end

  scenario "não deveria ser acessivel sem login" do
    click_link "Sair"
#    save_and_open_page
    visit banco_de_hora_path(@banco)
    page.should have_content(I18n.t("devise.failure.unauthenticated"))
  end

  before(:each) do
    usuario = desenvolvedor_faz_login
    @banco = FactoryGirl.create(:banco_de_hora, :usuario_id => usuario.id)
    @project = @banco.projeto
  end
end
