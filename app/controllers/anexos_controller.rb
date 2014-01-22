class AnexosController < ApplicationController

  def download
    anexo = Anexo.find params[:id]
    if current_usuario.id == anexo.usuario_id or current_usuario.role == "admin"
      path = "/#{anexo.arquivo}"
      send_file path, :x_sendfile=>true
    else
      redirect_to :back
    end
  end

end
