class HomeController < ApplicationController
  def index
    # Usuario.new(
      # :nome => "admin",
      # :email => "admin@admin.com",
      # :password => "admin",
      # :role => "admin").save
    
    
    if !usuario_signed_in?
      redirect_to new_usuario_session_url, :alert => I18n.t("devise.failure.unauthenticated")
    end
  end
end
