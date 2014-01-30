class ApplicationController < ActionController::Base
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_action :block_inactive
  protect_from_forgery

  helper_method :javascript_include_view_js

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end

  def javascript_include_view_js
    if FileTest.exists? "app/assets/javascripts/"+params[:controller]+"/"+params[:action]+".js"
      return "/assets/" + params[:controller] + "/" + params[:action]
    end
  end

  def current_user
    current_usuario
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  protected
  def block_inactive
    if current_user.present? and current_user.status == false
      sign_out current_user
      flash[:error] = "Seu perfil está bloqueado. Caso esteja recebendo esta mensagem por engano entre em contato com os administradores"
      redirect_to new_usuario_session_path
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :nome
    devise_parameter_sanitizer.for(:sign_up) << :role
  end

  private

  def dias_no_periodo(inicio, fim)
    (inicio..fim).collect{|d| d.day}
  end

  def to_boolean(string)
    if string.blank? or string == 'nil'
      return nil
    elsif string == "true"
      return true
    else
      return false
    end
  end

  def date_from_object(obj)
    if obj.class == Date
      obj
    elsif obj.class == String
      Date.parse(obj)
    else
      if Date.valid_date?(obj[:year].to_i, obj[:month].to_i, obj[:day].to_i)
        Date.new(obj[:year].to_i, obj[:month].to_i, obj[:day].to_i)
      else
        Date.new(obj[:year].to_i, obj[:month].to_i, 1).at_end_of_month
      end
    end
  end

end
