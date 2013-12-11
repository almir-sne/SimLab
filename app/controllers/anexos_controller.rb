class AnexosController < ApplicationController
  load_and_authorize_resource

  def download
    anexo = Anexo.find params[:id]
    path = "/#{anexo.arquivo}"
    send_file path, :x_sendfile=>true
  end
  
  private
  def anexo_params
     params.require(:anexo).permit(:arquivo, :nome, :tipo, :usuario_id, :pagamento_id, :ausencia_id, :data)
  end
end
