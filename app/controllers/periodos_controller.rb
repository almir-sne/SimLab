class PeriodosController < ApplicationController
  def periodos
    @ano = params[:ano] || Date.today.year
    @usuario = params[:usuario] || current_user
    @usuarios = Usuario.order(:nome)
    @periodos = (1..12).collect{|m| {inicio: Date.new(2013, m, 1), fim: Date.new(2013, m, 1).at_end_of_month}}
  end
end
