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
    @rodadas = @cartao.estimativas.group_by(&:rodada)
  end
  
  def create
    cartao = Cartao.where(trello_id: params[:cartao_id]).first
    estimativa = Estimativa.find_or_create_by_cartao_id_and_usuario_id_and_rodada(
      cartao.id, current_user.id, cartao.rodada)
    estimativa.valor = params[:estimativa]
    estimativa.save
    redirect_to cartao_estimativas_path(cartao_id: params[:cartao_id])
  end
  
  def fechar_rodada
    cartao = Cartao.where(trello_id: params[:cartao_id]).first
    cartao.estimado = true
    cartao.save
    redirect_to cartao_estimativas_path(cartao_id: params[:cartao_id])
  end
  
  def nova_rodada
    cartao = Cartao.where(trello_id: params[:cartao_id]).first
    cartao.estimado = false
    cartao.rodada += 1
    cartao.save
    redirect_to cartao_estimativas_path(cartao_id: params[:cartao_id])
  end
  
  def concluir
    cartao = Cartao.where(trello_id: params[:cartao_id]).first
    cartao.estimado = true
    cartao.estimativa = params[:estimativa_final]
    cartao.save
    redirect_to cartao_estimativas_path(cartao_id: params[:cartao_id])
  end
end
