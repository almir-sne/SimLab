class ResumoController < ApplicationController
  before_filter :authenticate_usuario!, :except => [:show, :index]

  def index
    @horas = Resumo.horas_no_mes current_usuario
  end
  
  def show
  	tipo_de_consulta = params[:id]
  	@horas_feitas
  	if tipo_de_consulta == "hora_dia_p_pessoa"
  		render :template =>"resumo/asd"
  	end
  end

end
