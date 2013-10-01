class ApplicationController < ActionController::Base
  before_filter :block_inactive
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

  private
  def lista_dias_no_mes(ano, mes)
    data_final = Date.new(ano, mes, 5).at_end_of_month.day
    (1..data_final).to_a
  end
  
  def lista_dias_no_mes_limitado(ano, mes)
    data_atual = Date.today
    #monta a data minima
    data_limite = data_atual - 4.days
    #verificar se o mes atual está na data limite
    if mes != data_limite.month and mes != data_atual.month
      #fora do range
      [].to_a
    elsif mes == data_limite.month and mes != data_atual.month
      #está perto do fim do mes da data limite
      data_inicio = data_limite.day
      data_fim = Date.new(ano, mes, 5).at_end_of_month.day
      (data_inicio..data_fim).to_a
    elsif mes == data_atual.month and mes != data_limite.month
      #esta perto do inicio do mes da data atual
      data_inicio = 1
      data_fim = data_atual.day
      (data_inicio..data_fim).to_a
    else
      #está no meio do mes
      data_inicio = data_limite.day
      data_fim = data_atual.day
      (data_inicio..data_fim).to_a
    end 
    #data_final = Date.new(ano, mes, 5).at_end_of_month.day
    #(1..data_final).to_a
  end
  def anos_selecionados(param_anos, hoje)
    if param_anos.nil?
      hoje.year
    elsif param_anos == "-1"
      [2012,2013,2014]
    else
      param_anos
    end
  end

  def meses_selecionados(param_meses, hoje)
    if param_meses.nil?
      return hoje.month
    elsif param_meses == "-1"
      (1..12).to_a
    else
      param_meses
    end
  end

  def usuarios_selecionados(param_usuarios)
    if param_usuarios.nil? || param_usuarios == "-1"
      Usuario.select(:id)
    else
      Usuario.where(:id => param_usuarios.to_i)
    end
  end

  def projetos_selecionados(param_projetos)
    if param_projetos.nil? || param_projetos == "-1"
      Projeto.select(:id)
    else
      Projeto.where(:id => param_projetos .to_i)
    end
  end
  
  def to_boolean(string)
    if string.blank?
      return nil
    elsif string == "true"
      return true
    else
      return false
    end
  end
  
end
