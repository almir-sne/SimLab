class EstimativasController < ApplicationController
  def index
    @projetos_boards = current_user.boards.pluck(:board_id).uniq
  end

  def board
    @board = params[:board_id]
  end

  def cartao
    @cartao = Cartao.find_or_create_by_trello_id(params[:cartao_id])
    if @cartao.rodada.blank?
      @cartao.rodada = 1
      @cartao.save
    end
    @estimativa = Estimativa.find_or_create_by_cartao_id_and_usuario_id_and_rodada(
      @cartao.id, current_usuario.id, @cartao.rodada)
    @estimativa_list = [["0.0", 0.0], ["0.5", 0.5],
            ["1", 1.0], ["2", 2.0], ["3", 3.0], ["5", 5.0], ["8", 8.0], ["13", 13.0], ["20", 20.0],
            ["40", 40.0], ["Infinito", -2.0], ["?", -1.0]]
    @rodadas = @cartao.estimativas.group_by(&:rodada)
    @ultima_rodada = @rodadas.size
  end
  
  def create
    cartao = Cartao.where(trello_id: params[:cartao_id]).first
    unless params[:estimativa].blank?
      estimativa = Estimativa.find_or_create_by_cartao_id_and_usuario_id_and_rodada(
        cartao.id, current_user.id, cartao.rodada)
      estimativa.valor = params[:estimativa]
      estimativa.save
    end

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
