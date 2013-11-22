class AnexosController < ApplicationController
  load_and_authorize_resource

  def download
    anexo = Anexo.find params[:id]
    path = "/#{anexo.arquivo}"
    send_file path, :x_sendfile=>true
  end

end
