class ResumoController < ApplicationController

  def show # tenho q arrumar as rotas....
  	tipo_de_consulta = params[:id]

    case tipo_de_consulta

  	when "horas_por_dia_por_pessoa"
  		@horas = Resumo.horas_no_dia_de current_usuario
  		render :template =>"resumo/horas_por_dia_por_pessoa"

  	when "horas_por_mes_por_pessoa"
  	  @horas = Resumo.horas_no_mes_de current_usuario
  	  render :template =>"resumo/horas_por_mes_por_pessoa"

  	when "horas_e_investimento_por_projeto"
  	  @horas_e_investimento = Resumo.horas_e_investimento_nos_projetos
  	  render :template =>"resumo/horas_e_investimento_por_projeto"
    end

  end

end
