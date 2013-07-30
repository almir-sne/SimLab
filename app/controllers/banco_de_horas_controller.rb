class BancoDeHorasController < ApplicationController
  before_filter :authenticate_usuario!
  def index
    @year =      params[:year].nil?  ? Date.today.year  : params[:year]
    @user =      params[:user].nil?  ? current_user     : Usuario.find(params[:user])
    @month_num = params[:month].nil? ? Date.today.month : params[:month]

    @month = Mes.find_or_initialize_by_ano_and_numero_and_usuario_id @year, @month_num, @user.id
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
    Rails.logger.info(@dia.errors.messages.inspect).inspect

    atividades_failure = false
    params[:dia][:atividades_attributes].each do |lixo, atividade_attr|
      atividade = Atividade.new(
        :duracao => atividade_attr["duracao(4i)"].to_i * 3600 +  atividade_attr["duracao(5i)"].to_i * 60,
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

  def update
    dia = Dia.find(params[:id])

    respond_to do |format|
      if dia.update_attributes(
        :numero => params[:dia][:numero],
        :entrada => convert_date(params[:dia], "entrada"),
        :saida => convert_date(params[:dia], "saida"),
        :intervalo => (params[:dia]["intervalo_time(4i)"].to_i * 3600 +  params[:dia]["intervalo_time(5i)"].to_i * 60),
        :mes_id => params[:mes],
        :usuario_id => params[:user_id]
      )
        format.html { redirect_to @projeto, notice: I18n.t("dia.update.sucess") }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @projeto.errors, status: :unprocessable_entity }
      end
     flash[:notice] = I18n.t("dia.update.sucess")
      redirect_to :back
    return
    end
  end

  def show_mes
    @year = params[:year].nil? ? Date.today.year : params[:year]
    @user = params[:user_id].nil? ? current_user : Usuario.find(params[:user_id])
    query = Mes.find_all_by_ano_and_usuario_id @year, @user.id
    @meses = {}
    query.map {|e| @meses[e.numero] = e }
  end

  def validar
    usuario_id = (params[:usuario_id].nil? || params[:usuario_id] == "TODOS") ? Usuario.all.map{|usuario| usuario.id } : params[:usuario_id]
    @ano = params[:ano].nil? ? Date.today.year : params[:ano]
    @mes_numero = params[:mes].nil? ? Date.today.month : params[:mes]
    meses_id = Mes.find_all_by_numero_and_ano(@mes_numero, @ano).map{|month| month.id }
    authorize! :update, :validations
    @atividades =  Atividade.where(:aprovacao => [false, nil], :mes_id => meses_id, :usuario_id => usuario_id).all

    soma =  @atividades.map{|atividade| atividade.duracao}.inject{|sum, x| sum + x}
    @total_horas = soma.nil? ? 0:  (soma/3600).round(2)

  end

  def mandar_validacao
    authorize! :update, :validations

    atividades = params[:atividades].try(:keys)
    atividades ||= []

    for i in atividades
      ativ = params[:atividades][i.to_str]
      if ativ["reprovacao"]
        veredito = false
      elsif ativ["aprovacao"]
        veredito = true
      else
        veredito = nil
      end
      Atividade.find(ativ["id"].to_i).update_attributes(:aprovacao => veredito, :mensagem => ativ["mensagem"])
    end

    flash[:notice] = I18n.t("banco_de_horas.validation.sucess")
    redirect_to :back
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
