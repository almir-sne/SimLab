class EstimativasController < ApplicationController
  def index
    @projetos_boards = current_user.boards.pluck(:board_id).uniq
  end

  def board
    @board = params[:board_id]
  end

  def cartao
    @cartao = Cartao.find_or_create_by_trello_id(params[:cartao_id])
    @decks = Deck.all
  end
  
  def create
    cartao = Cartao.find params[:cartao_id]
    estimativa = Estimativa.find_or_initialize_by_cartao_id_and_usuario_id_and_rodada_id(
      cartao.id, current_user.id, params[:rodada_id])
    estimativa.planning_card_id = params[:planning_card_id]
    estimativa.save
    respond_to do |format|
      format.js
    end
  end
  
  def fechar_rodada
    cartao = Cartao.find params[:cartao_id]
    cartao.fechar_rodada(current_user)
    respond_to do |format|
      format.js
    end
  end
  
  def nova_rodada
    cartao = Cartao.find params[:cartao_id]
    Rodada.new(cartao_id: params[:cartao_id], inicio: Time.now,
      criador_id: current_user.id, deck_id: params[:deck_id], fechada: false,
      numero: cartao.rodadas.maximum(:numero).to_i + 1).save
    cartao.save
    respond_to do |format|
      format.js
    end
  end
  
  def concluir
    @cartao = Cartao.find params[:cartao_id]
    @cartao.estimativa = params[:estimativa_final]
    @cartao.save
    respond_to do |format|
      format.js
    end
  end
end
