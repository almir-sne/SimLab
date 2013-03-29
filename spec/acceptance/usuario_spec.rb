require 'spec_helper'

feature "Usuário" do
  include Helpers
  scenario 'deve poder se cadastrar no site' do
    visit new_usuario_registration_path
    fill_in "Email", :with => @visitante[:email]
    fill_in "Nome", :with => @visitante[:nome]
    fill_in "usuario_password", :with => @visitante[:password]
    fill_in "usuario_password_confirmation", :with => @visitante[:password]
    click_button  I18n.t("devise.registrations.new.submit")
    page.should have_content I18n.t("devise.registrations.signed_up")
  end
  
  scenario 'deve poder fazer login' do
    usuario_faz_login
    page.should have_content I18n.t("devise.sessions.signed_in")
  end
  
  scenario 'deve poder editar suas informações' do
    usuario_faz_login
    visit edit_usuario_registration_path
    fill_in "Nome", :with => "Teste"
    fill_in "Current password", :with => "12345678"
    click_button I18n.t("devise.registrations.edit.update")
    page.should have_content I18n.t("devise.registrations.updated")
  end
  
  scenario 'deve poder fazer logout' do
    usuario_faz_login
    click_link "Sair"
    page.should have_content "Remember me"
  end
  
  before(:all) do
    @visitante = {nome: "Teste", email: "user@example.com", password: "12345678"}
  end
end
