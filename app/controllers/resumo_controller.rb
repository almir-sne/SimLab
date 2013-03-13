class ResumoController < ApplicationController
  before_filter :authenticate_usuario!, :except => [:show, :index]

  def index
    @horas = Resumo.horas_do_mes current_usuario
  end

end
