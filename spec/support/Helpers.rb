module Helpers
  def usuario_faz_login
    usuario = FactoryGirl.create(:usuario)
    visit new_usuario_session_path
    fill_in "usuario_email", :with => usuario.email
    fill_in "usuario_password", :with => "12345678"
    click_button I18n.t("devise.sessions.new.submit")
    usuario
  end
end