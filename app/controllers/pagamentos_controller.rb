class PagamentosController < ApplicationController
  load_and_authorize_resource
  
  def index
    @usuarios = Usuario.order(:nome)
  end

  def meses
    if can? :manage, Pagamento
      @usuario = Usuario.find params[:user_id]
    else
      @usuario = current_usuario
    end
    @meses =  Mes.where("usuario_id = ? and ano is not null and numero is not null and numero between 1 and 12",
      @usuario.id).order('ano desc', 'numero desc')
  end

  def listar
    @mes = Mes.find params[:mes_id]
  end
  
  def create_or_update
    @mes = Mes.find params[:mes_id]
    if @mes.update_attributes(params[:mes])
      flash[:notice] = "Pagamento(s) registrado(s) com sucesso"
    else
      flash[:notice] = "Erro durante atualização de registros"
    end
    redirect_to listar_pagamentos_path(:mes_id => @mes.id)
  end
end
