class BancoDeHorasController < ApplicationController
  before_filter :authenticate_usuario!
  # GET /banco_de_horas
  # GET /banco_de_horas.json
  def index
    @banco_de_horas = BancoDeHora.all

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
    @banco_de_hora = BancoDeHora.new(params[:banco_de_hora])

    respond_to do |format|
      if @banco_de_hora.save
        format.html { redirect_to @banco_de_hora, notice: I18n.t("banco_de_horas.create.sucess") }
        format.json { render json: @banco_de_hora, status: :created, location: @banco_de_hora }
      else
        format.html { render action: "new" }
        format.json { render json: @banco_de_hora.errors, status: :unprocessable_entity }
      end
    end
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
end
