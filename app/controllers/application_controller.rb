class ApplicationController < ActionController::Base
  protect_from_forgery
  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end

  def current_user
    current_usuario
  end

end
