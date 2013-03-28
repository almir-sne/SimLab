module Helpers
  def usuario_faz_login
    @usuario = FactoryGirl.create(:usuario)
    visit new_usuario_session_path
    fill_in "Email", :with => @usuario.email
    fill_in "Password", :with => "12345678"
    click_button I18n.t("devise.sessions.new.submit")
  end
end