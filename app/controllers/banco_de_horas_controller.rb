class BancoDeHorasController < ApplicationController
  before_filter :authenticate_usuario!
  def index
    @year =      params[:year].nil?  ? Date.today.year  : params[:year]
    @user =      params[:user].nil?  ? current_user     : Usuario.find(params[:user])
    @month_num = params[:month].nil? ? Date.today.month : params[:month]

    @month = Mes.find_or_initialize_by_ano_and_numero_and_user_id @year, @month_num, @user.id
    if @month.horas_contratadas.nil?
      @month.horas_contratadas = @user.horario_mensal
      @month.valor_hora = @user.valor_da_hora
      @month.save
    end

    @dias = @month.dias
    @dias.sort_by! { |d| d.numero  }
    @dia = Dia.new
    @dia.atividades.build
  end

  def create
    @dia = Dia.new(
      :numero => params[:dia][:numero],
      :entrada => convert_date(params[:dia], "entrada"),
      :saida => convert_date(params[:dia], "saida"),
      :intervalo => (params[:dia]["intervalo(4i)"].to_i * 3600 +  params[:dia]["intervalo(5i)"].to_i * 60),
      :mes_id => params[:mes],
      :usuario_id => params[:user_id]
    )
    dia_sucess = @dia.save

    atividades_failure = false
    params[:dia][:atividades_attributes].each do |lixo, atividade_attr|
      atividade = Atividade.new(
        :horas => atividade_attr["horas(4i)"].to_i * 3600 +  atividade_attr["horas(5i)"].to_i * 60,
        :observacao => atividade_attr["observacao"],
        :projeto_id => atividade_attr["projeto_id"],
        :dia_id => @dia.id,
        :mes_id => params[:mes],
        :usuario_id => params[:user_id]
      )
      atividades_failure = ! atividade.save
    end

    if dia_sucess and !atividades_failure
      flash[:notice] = I18n.t("banco_de_horas.create.sucess")
    else
      flash[:error] = I18n.t("banco_de_horas.create.failure")
    end
    redirect_to banco_de_horas_path(:month => Mes.find(params[:mes]).numero, :year => params[:ano], :user => params[:user_id])
  end

  def show_mes
    @year = params[:year].nil? ? Date.today.year : params[:year]
    @user = params[:user_id].nil? ? current_user : Usuario.find(params[:user_id])
    query = Mes.find_all_by_ano_and_user_id @year, @user.id
    @meses = {}
    query.map {|e| @meses[e.numero] = e }
  end

  def validar
    @ano = params[:ano].nil? ? Date.today.year : params[:ano]
    @mes_numero = params[:mes].nil? ? Date.today.month : params[:mes]
    meses_id = Mes.find_all_by_numero_and_ano(@mes_numero, @ano).map{|month| month.id }
    authorize! :update, :validations
    @atividades =  Atividade.where(:aprovacao => [false, nil], :mes_id => meses_id).all.sort{ |a,b| a.data <=> b.data }
  end

  def mandar_validacao
    authorize! :update, :validations

    atividades = params[:atividades].try(:keys)

    atividades ||= []

    for i in atividades
      ativ = params[:atividades][i.to_str]
      mensagem = nil
      if ativ["aprovacao"] == "false"
        aprovacao = false
        mensagem = ativ["mensagem"]
      end
      Atividade.find(ativ["id"].to_i).update_attributes(:aprovacao => ativ["aprovacao"], :mensagem => mensagem)
    end

    flash[:notice] = I18n.t("banco_de_horas.validation.sucess")
    redirect_to validar_banco_de_horas_path
  end

  def delete_dia
    dia = Dia.find params[:dia_id]
    dia.destroy
    redirect_to :back
  end

  private

  def convert_date(hash, date_symbol_or_string)
    attribute = date_symbol_or_string.to_s
    return DateTime.new(
      hash[attribute + '(1i)'].to_i,
      hash[attribute + '(2i)'].to_i,
      hash[attribute + '(3i)'].to_i,
      hash[attribute + '(4i)'].to_i,
      hash[attribute + '(5i)'].to_i)
  end
end
