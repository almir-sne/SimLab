class RecursosController < ApplicationController

  def index
    mes_numero = params[:mes]
    ano        = params[:ano]

    meses = Mes.find_all_by_ano_and_numero ano, mes_numero
    pessoas = meses.select{|z| !(z.valor_hora.nil?) &&  !(Usuario.find(z.usuario_id).valor_da_bolsa_fau.nil?)}
    pessoas.map!{|mes|[
      Usuario.find(mes.usuario_id).nome,
      mes.valor_hora * mes.horas_trabalhadas - Usuario.find(mes.usuario_id).valor_da_bolsa_fau,
      mes.id
      ]}
    @pessoas = pessoas.select{|nome, valor_diferenca| valor_diferenca > 0}
  end

end
