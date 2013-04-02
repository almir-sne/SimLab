class HomeController < ApplicationController
  def index
    if !usuario_signed_in?
      redirect_to new_usuario_session_url, :alert => I18n.t("devise.failure.unauthenticated")
    end
  end
end
