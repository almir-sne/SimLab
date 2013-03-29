require 'spec_helper'

feature "Banco de horas" do
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
  
  before do
    usuario = usuario_faz_login
    @project = FactoryGirl.create(:projeto)
    @banco = FactoryGirl.create(:banco_de_hora, :usuario_id => usuario.id)
  end
end
