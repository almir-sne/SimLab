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
    pessoas.map! do |mes|
      pessoa = Usuario.find(mes.usuario_id)
      rec_nao_existe = Recursos.where(:mes_id  => mes.id).blank?
      {
        :nome    => pessoa.nome,
        :valor   => mes.valor_hora * mes.horas_trabalhadas[0..-4].to_i - pessoa.valor_da_bolsa_fau,
        :banco   => pessoa.banco,
        :agencia => pessoa.agencia,
        :conta   => pessoa.conta,
        :mes_id  => mes.id,
        :is_origem_1 => rec_nao_existe ? false : (Recursos.where(:mes_id  => mes.id).first.origem_id == 1 ),
        :is_origem_2 => rec_nao_existe ? false : (Recursos.where(:mes_id  => mes.id).first.origem_id == 2 )
      }
    end
    @pessoas = pessoas.select{|pessoa| pessoa[:valor] > 0}

  end

  def create
    authorize! :create, :recurso

    recursos = params[:recurso]
    recursos.each do |numero, recurso|
      rec = Recursos.where(recurso.except(:origem_id)).first_or_initialize
      rec.origem_id = recurso[:origem_id]
      unless rec.save
        flash[:notice] = I18n.t("recursos.create.failure")
      end
    end

    flash[:notice] = I18n.t("recursos.create.sucess")
    redirect_to :back
  end

end
