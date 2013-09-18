class PagamentosController < ApplicationController
  def index
    @usuarios = Usuario.order(:nome)
  end

  def meses
    @usuario = Usuario.find params[:user_id]
    @meses =  Mes.where("usuario_id = ? and ano is not null and numero is not null and numero between 1 and 12",
      @usuario.id).order('ano desc', 'numero desc')
  end

  def listar
    @mes = Mes.find params[:mes_id]
  end
  
  def update
    
  end
end
