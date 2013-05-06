class BancoDeHorasController < ApplicationController
  before_filter :authenticate_usuario!
  # GET /banco_de_horas
  # GET /banco_de_horas.json
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
    @dia = Dia.new
    @dia.atividades.build
  end

  # GET /banco_de_horas/1
  # GET /banco_de_horas/1.json
  def show
    @banco_de_hora = BancoDeHora.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @banco_de_hora }
    end
  end

  # GET /banco_de_horas/new
  # GET /banco_de_horas/new.json


  # GET /banco_de_horas/1/edit
  def edit
    @projetos = Projeto.all
    @banco_de_hora = BancoDeHora.find(params[:id])
  end

  # POST /banco_de_horas
  # POST /banco_de_horas.json
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
        :user_id => params[:user_id]
      )
      atividades_failure = ! atividade.save
    end

    if dia_sucess and !atividades_failure
      flash[:notice] = I18n.t("banco_de_horas.create.sucess")
    else
      flash[:error] = "Erro na criação do registro"
    end
    redirect_to banco_de_horas_path(:month => Mes.find(params[:mes]).numero, :year => params[:ano], :user => params[:user_id])
  end

  # PUT /banco_de_horas/1
  # PUT /banco_de_horas/1.json
  def update
    @banco_de_hora = BancoDeHora.find(params[:id])

    respond_to do |format|
      if @banco_de_hora.update_attributes(params[:banco_de_hora])
        format.html { redirect_to @banco_de_hora, notice: I18n.t("banco_de_horas.update.sucess") }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @banco_de_hora.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /banco_de_horas/1
  # DELETE /banco_de_horas/1.json
  def destroy
    @banco_de_hora = BancoDeHora.find(params[:id])
    @banco_de_hora.destroy

    respond_to do |format|
      format.html { redirect_to banco_de_horas_url }
      format.json { head :no_content }
    end
  end

  def modal
    @dia = Dia.new
  end

  def show_mes
    @year = params[:year].nil? ? Date.today.year : params[:year]
    @user = current_user
    query = Mes.find_all_by_ano_and_user_id @year, @user.id
    @meses = {}
    query.map {|e| @meses[e.numero] = e }
  end

  def validar
     authorize! :update, :validations
    @atividades =  Atividade.where(:aprovacao => [false, nil]).all
  end

  def mandar_validacao
    authorize! :update, :validations

    aprovados = params[:aprovacao][:aprovado].try(:keys)
    reprovados = params[:aprovacao][:reprovado].try(:keys)

    aprovados ||= []
    reprovados ||= []

    for i in aprovados
      Atividade.find(i).update_attribute :aprovacao, true
    end

    for i in reprovados
      Atividade.find(i).update_attribute :aprovacao, false
    end

    flash[:notice] = I18n.t("banco_de_horas.validation.sucess")
    redirect_to validar_banco_de_horas_path
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
