class Android::MesesController < ApplicationController
  before_filter :verify_authenticity_token
  respond_to :json
  def dias
    mes = Mes.find params[:id]
    @dias = mes.dias
    respond_with({
        dias: @dias.as_json(:only => [:entrada, :saida, :numero, :intervalo, :atividades_attributes]),
      })
  end

  def index
    @meses = Mes.where(:usuario_id => params[:usuario], :ano => params[:ano])
    respond_with({
        meses: @meses.as_json(:only => [:id, :numero], :methods => [:tem_reprovacao?, :horas_trabalhadas_aprovadas])
      })
  end
end
