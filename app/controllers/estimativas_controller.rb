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
    #    @rodadas = @cartao.estimativas.where("valor is not null").group_by(&:rodada)
  end
  
  def create
    cartao = Cartao.find params[:cartao_id]
    estimativa = Estimativa.find_or_initialize_by_cartao_id_and_usuario_id_and_rodada_id(
      cartao.id, current_user.id, params[:rodada_id])
    estimativa.planning_card_id = params[:planning_card_id]
    estimativa.save
    redirect_to cartao_estimativas_path(cartao_id: cartao.trello_id)
  end
  
  def fechar_rodada
    cartao = Cartao.where(trello_id: params[:cartao_id]).first
    cartao.estimado = true
    rodada = cartao.rodadas.where(fechado: false).last
    rodada.fechada = true
    rodada.fim = Time.now
    rodada.finalizador = current_user
    rodada.save
    cartao.save
    redirect_to cartao_estimativas_path(cartao_id: params[:cartao_id])
  end
  
  def nova_rodada
    cartao = Cartao.find params[:cartao_id]
    cartao.estimado = false
    Rodada.new(cartao_id: params[:cartao_id], inicio: Time.now,
      criador_id: current_user.id, deck_id: params[:deck_id], fechada: false,
      numero: cartao.rodadas.maximum(:numero).to_i + 1).save
    cartao.save
    redirect_to cartao_estimativas_path(cartao_id: cartao.trello_id)
  end
  
  def concluir
    cartao = Cartao.where(trello_id: params[:cartao_id]).first
    cartao.estimado = true
    cartao.estimativa = params[:estimativa_final]
    cartao.save
    redirect_to cartao_estimativas_path(cartao_id: params[:cartao_id])
  end
end
