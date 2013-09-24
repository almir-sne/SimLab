class AusenciasController < ApplicationController
  def destroy
    dia = Dia.find params[:id]
    dia.destroy
    redirect_to :back
  end
  
  def create
    @ausencia = Ausencia.new(params[:ausencia])
    if @ausencia.save
      flash[:notice] = I18n.t("banco_de_horas.create.sucess")
    else
      flash[:error] = I18n.t("banco_de_horas.create.failure")
    end
    redirect_to banco_de_horas_path(:month => @ausencia.mes.numero,
      :year => @ausencia.mes.ano, :user => @ausencia.usuario.id)
  end
end
