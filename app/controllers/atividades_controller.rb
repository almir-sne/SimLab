class AtividadesController < ApplicationController
  before_filter :authenticate_usuario!

  def minhas
    dia_id = params[:dia_id]
    @atividades = Atividade.find_all_by_dia_id_and_user_id(dia_id, current_usuario)
  end

end
