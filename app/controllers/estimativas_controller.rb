class EstimativasController < ApplicationController
  def index
    @projetos_boards = current_user.boards.pluck(:board_id).uniq
  end

  def board
    @board = params[:board_id]
  end

  def cartao
    @cartao = Cartao.where(trello_id: params[:cartao_id]).first
    if @cartao.blank?
      @cartao = Cartao.new(trello_id: params[:cartao_id], rodada: 1)
      @cartao.save
    end
    @estimativa = Estimativa.find_or_create_by_cartao_id_and_usuario_id_and_rodada(
      @cartao.id, current_usuario.id, @cartao.rodada)
    debugger
    @estimativas = Estimativa.where(cartao_id: @cartao.id)
  end
  
  def create
    cartao = Cartao.where(trello_id: params[:cartao_id]).first
    estimativa = Estimativa.find_or_create_by_cartao_id_and_usuario_id_and_rodada(
      cartao.id, current_user.id, cartao.rodada)
    estimativa.valor = params[:estimativa]
    estimativa.save
    redirect_to cartao_estimativas_path(cartao_id: params[:cartao_id])
  end
end
