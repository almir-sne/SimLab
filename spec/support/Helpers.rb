module Helpers
  def desenvolvedor_faz_login
    usuario = FactoryGirl.create(:desenvolvedor)
    contrato = FactoryGirl.create(:contrato)
    projeto = FactoryGirl.create(:projeto)
    usuario.projetos = Projeto.all
    visit new_usuario_session_path
    fill_in "usuario_email", :with => usuario.email
    fill_in "usuario_password", :with => "12345678"
    click_button I18n.t("devise.sessions.new.submit")
    usuario
  end

  def coordenador_faz_login
    usuario = FactoryGirl.create(:coordenador)
    visit new_usuario_session_path
    fill_in "usuario_email", :with => usuario.email
    fill_in "usuario_password", :with => "12345678"
    click_button I18n.t("devise.sessions.new.submit")
    usuario
  end

  def admin_faz_login
    usuario = FactoryGirl.create(:admin)
    contrato = FactoryGirl.create(:contrato)
    projeto = FactoryGirl.create(:projeto)
    usuario.projetos = Projeto.all
    visit new_usuario_session_path
    fill_in "usuario_email", :with => usuario.email
    fill_in "usuario_password", :with => "12345678"
    click_button I18n.t("devise.sessions.new.submit")
    usuario
  end
end
