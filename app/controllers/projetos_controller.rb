class ProjetosController < ApplicationController
  before_filter :authenticate_usuario!

  # GET /projetos
  # GET /projetos.json
  def index
    @projetos = Projeto.all(:order => :nome)
    @projeto = Projeto.new

    @projetos.each do |projeto|
      projeto.update_attribute :horas_totais, calcula_horas_totais_do_projeto(projeto.id)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projetos }
    end
  end

  # GET /projetos/1
  # GET /projetos/1.json
  def show
    authorize! :read, Projeto
    @projeto = Projeto.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @projeto }
    end
  end

  # GET /projetos/new
  # GET /projetos/new.json
  def new
    authorize! :create, Projeto
    @projeto = Projeto.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @projeto }
    end
  end

  # GET /projetos/1/edit
  def edit
    authorize! :create, Projeto
    @projeto = Projeto.find(params[:id])
  end

  # POST /projetos
  # POST /projetos.json
  def create
    authorize! :create, Projeto
    @projeto = Projeto.new(params[:projeto])
    if @projeto.save
      redirect_to projetos_path, notice: I18n.t("projetos.create.sucess")
    else
      puts @projeto.errors
      flash[:errors] = I18n.t("projetos.create.failure")
      redirect_to projetos_path
    end
  end

  # PUT /projetos/1
  # PUT /projetos/1.json
  def update
    authorize! :create, Projeto
    @projeto = Projeto.find(params[:id])

    respond_to do |format|
      if @projeto.update_attributes(params[:projeto])
        format.html { redirect_to projetos_path, notice: I18n.t("projetos.update.sucess") }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @projeto.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projetos/1
  # DELETE /projetos/1.json
  def destroy
    authorize! :destroy, Projeto
    @projeto = Projeto.find(params[:id])
    @projeto.destroy

    respond_to do |format|
      format.html { redirect_to projetos_url }
      format.json { head :no_content }
    end
  end

  private
  def calcula_horas_totais_do_projeto(id)
    usuarios_ids = Workon.where(:projeto_id => id).collect{|work| work.usuario_id}
    duracao_das_atividades = Atividade.where(:projeto_id => id, :aprovacao => true, :usuario_id => usuarios_ids).collect{|atividade| atividade.duracao}
    horas_totais   = duracao_das_atividades.inject{|sum, sec| sum + sec}
    horas_totais.nil? ? 0 : horas_totais/ 3600
  end
end
