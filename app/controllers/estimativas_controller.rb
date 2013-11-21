class EstimativasController < ApplicationController
  def index
    @projetos_boards = current_user.boards.pluck(:board_id).uniq
  end

  def board
    @board = params[:board_id]
  end

  def cartao
  end
  
  def estimar
    
  end
end
