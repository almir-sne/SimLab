require 'spec_helper'

def set_up

end

describe "Usuário" do
  it 'Faz seu cadastro' do
    visit new_usuario_registration_path
    fill_in "Email", :with => @visitante[:email]
    fill_in "Nome", :with => @visitante[:nome]
    fill_in "usuario_password", :with => @visitante[:password]
    fill_in "usuario_password_confirmation", :with => @visitante[:password]
    click_button "Registrar"
#    save_and_open_page
    page.should have_content "Você se registrou com sucesso"
  end

  before(:all) do
    @visitante = {nome: "Teste", email: "user@example2.com", password: "12345678"}
  end
end
