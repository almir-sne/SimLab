class Android::ApiController < ApplicationController
  before_filter :verify_authenticity_token
  respond_to :json
  def dias
    mes = Mes.find params[:id]
    @dias = mes.dias
    respond_with({
        dias: @dias.as_json(:only => [:id, :numero], :methods => [:entradafmt, :saidafmt, :intervalofmt]),
      })
  end
  
  def atividades
    dia = Dia.find params[:dia_id]
    respond_with(
        dia.atividades.as_json(:only => [:aprovacao, :id, :duracao, :mensagem, :observacao, :projeto_id, :usuario_id])
    )
  end
  
  def projetos
    usuario = Usuario.where(authentication_token: params[:auth_token]).last
    respond_with(
        usuario.projetos.as_json(:only => [:id, :nome])
    )
  end
  
  def dias_update
    
  end

  def meses
    usuario = Usuario.where(authentication_token: params[:auth_token]).last
    @meses = Mes.where(:usuario_id => usuario.id, :ano => params[:ano])
    respond_with({
        meses: @meses.as_json(:only => [:id, :numero], :methods => [:tem_reprovacao?, :horas_trabalhadas_aprovadas])
      })
  end
end
