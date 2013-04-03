class BancoDeHorasController < ApplicationController
  load_and_authorize_resource
  # GET /banco_de_horas
  # GET /banco_de_horas.json
  def index
    @year = params[:year]
    @year ||= Date.today.year
    @user = Usuario.find params[:user] unless params[:user].blank?
    @user ||= current_user
    @month_num = params[:month]
    @month_num ||= Date.today.month
    @month = Mes.find_by_ano_and_numero_and_user_id @year, @month_num, @user.id
    if @month.nil?
      @month = Mes.new :ano => @year, :numero => @month_num, :horas_contratadas => @user.horario_mensal,
        :user_id => @user.id, :valor_hora => @user.valor_da_hora
      @month.save
    end
    @dias = @month.dias
    @dia = Dia.new
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @banco_de_horas }
    end
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
  def new
    @projetos = Projeto.all
    @banco_de_hora = BancoDeHora.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @banco_de_hora }
    end
  end

  # GET /banco_de_horas/1/edit
  def edit
    @projetos = Projeto.all
    @banco_de_hora = BancoDeHora.find(params[:id])
  end

  # POST /banco_de_horas
  # POST /banco_de_horas.json
  def create
    @dia = Dia.new(params[:dia])
    @dia.numero = params[:numero]
    e = params[:entrada].split(":")
    s = params[:saida].split(":")
    i = params[:intervalo].split(":")
    month = Mes.find params[:mes]
    entrada = DateTime.new(params[:ano].to_i, month.numero, @dia.numero, e[0].to_i + 2, e[1].to_i)
    saida = DateTime.new(params[:ano].to_i, month.numero, @dia.numero, s[0].to_i + 2, s[1].to_i)
    intervalo = i[0].to_f * 3600 + i[1].to_f * 60
    @dia.entrada = entrada
    @dia.saida = saida
    @dia.intervalo = intervalo
    @dia.mes = month
    @dia.usuario_id = params[:user_id]
    if @dia.save
      flash[:notice] = I18n.t("banco_de_horas.create.sucess")
    else
      flash[:error] = "Erro na criação do registro"
    end
    redirect_to banco_de_horas_path(:month => month.numero, :year => params[:ano], :user => params[:user_id])
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
    @year = params[:year]
    @year ||= Date.today.year
    @user = current_user
    query = Mes.find_all_by_ano_and_user_id @year, @user.id
    @meses = {}
    query.map {|e| @meses[e.numero] = e }
  end
end
