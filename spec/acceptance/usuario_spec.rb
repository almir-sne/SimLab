require 'spec_helper'

feature "Usuário" do
  scenario 'faz seu cadastro' do
    visit new_usuario_registration_path
    fill_in "Email", :with => @visitante[:email]
    fill_in "Nome", :with => @visitante[:nome]
    fill_in "usuario_password", :with => @visitante[:password]
    fill_in "usuario_password_confirmation", :with => @visitante[:password]
    click_button  I18n.t("devise.registrations.new.submit")
    page.should have_content I18n.t("messages.logged_in", :email => @visitante[:email])
  end
  
  scenario 'Faz login' do
    visit new_usuario_session_path
    user = FactoryGirl.create(:usuario)
    fill_in 'Email', :with => user.email
    fill_in 'Password', :with => user.password
    click_button I18n.t("devise.sessions.new.submit")
  end
  
  before(:all) do
    @visitante = {nome: "Teste", email: "user@example.com", password: "12345678"}
  end
end
