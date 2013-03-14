class ResumoController < ApplicationController
  before_filter :authenticate_usuario!, :except => [:show, :index]

  def index
    @horas = Resumo.horas_no_mes current_usuario
  end

end
