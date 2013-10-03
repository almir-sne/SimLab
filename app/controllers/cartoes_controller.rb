class CartoesController < ApplicationController
  load_and_authorize_resource

  def estatisticas
    cartoes = Cartao.group(:cartao_id).order("updated_at desc").pluck(:cartao_id)
    @stats = cartoes.collect {|id| {cartao_id: id,
        horas: Cartao.horas_trabalhadas_format(id), num_atividades: Cartao.where(cartao_id: id).count}}.
      paginate(:page => params[:page], :per_page => 30)
  end
  
  def atividades
    cartoes = Cartao.where(cartao_id: params[:cartao_id])
    @atividades = cartoes.collect{|cartao| cartao.atividade}
    @cartao_id = params[:cartao_id]
  end
end
