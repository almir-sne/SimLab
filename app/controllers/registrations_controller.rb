class RegistrationsController < Devise::RegistrationsController
 
  before_filter :configure_permitted_parameters
 
  protected 
  # my custom fields are :nome
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :password, :password_confirmation, :nome)
    end
  end 
end
