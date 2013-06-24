require 'spec_helper'

feature "Usuário" do
  include Helpers
  describe "admin" do
    scenario 'deve poder cadastrar pessoas no site' do
      admin_faz_login
      visit usuarios_path
      fill_in "Nome", :with => @visitante[:nome]
      fill_in "Email", :with => @visitante[:email]
      fill_in "usuario_password", :with => @visitante[:password]
      fill_in "usuario_password_confirmation", :with => @visitante[:password]
      click_button  "Salvar"
      page.should have_content I18n.t("devise.registrations.signed_up_another")
    end

    scenario 'admin deve poder editar pessoas no site' do
      coordenador = FactoryGirl.create :coordenador
      admin_faz_login
      visit usuarios_path
  #    save_and_open_page
      click_link coordenador.nome.to_s
      fill_in "Nome", :with => "Pedro"
      fill_in "Banco", :with => "ladrao"
      click_button "Salvar"
      page.should have_content "Successfully updated Usuario."
    end
  end

  describe "anyone" do
    scenario 'deve poder fazer login' do
      desenvolvedor_faz_login
      page.should have_content I18n.t("devise.sessions.signed_in")
    end

    scenario 'deve poder editar suas informações' do
      desenvolvedor_faz_login
      visit edit_usuario_registration_path
      fill_in "usuario_password", :with => "novasenha"
      fill_in "usuario_password_confirmation", :with => "novasenha"
      fill_in "usuario_current_password", :with => "12345678"
      click_button "Salvar"
      page.should have_content I18n.t("devise.registrations.updated")
    end

    scenario 'deve poder fazer logout' do
      desenvolvedor_faz_login
      click_link "Sair"
      page.should have_content "Remember me"
    end
  end

  before(:all) do
    @visitante = FactoryGirl.attributes_for(:desenvolvedor)
  end
end
