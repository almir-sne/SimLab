class RecursosController < ApplicationController

  def index
    authorize! :update, :validations

    @mes_numero = params[:mes]
    @ano        = params[:ano]

    meses   = Mes.find_all_by_ano_and_numero @ano, @mes_numero
    pessoas = meses.select{
      |z| !(z.valor_hora.nil?) &&
      !(Usuario.find(z.usuario_id).valor_da_bolsa_fau.nil?)
    }
    pessoas.map!{|mes| pessoa = Usuario.find(mes.usuario_id)
    {
      :nome    => pessoa.nome,
      :valor   => mes.valor_hora * mes.horas_trabalhadas - pessoa.valor_da_bolsa_fau,
      :banco   => pessoa.banco,
      :agencia => pessoa.agencia,
      :conta   => pessoa.conta,
      :mes_id  => mes.id
    }}
    @pessoas = pessoas.select{|pessoa| pessoa[:valor] > 0}
  end

end
