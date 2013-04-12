class ProjetosController < ApplicationController

  # GET /projetos
  # GET /projetos.json
  def index
    @projetos = Projeto.all
    @projeto = Projeto.new
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

    respond_to do |format|
      if @projeto.save
        format.html { redirect_to @projeto, notice: I18n.t("projetos.create.sucess")}
        format.json { render json: @projeto, status: :created, location: @projeto }
      else
        format.html { render action: "new" }
        format.json { render json: @projeto.errors, status: :unprocessable_entity }
      end
      redirect_to projetos_path
    return
    end
  end

  # PUT /projetos/1
  # PUT /projetos/1.json
  def update
    authorize! :create, Projeto
    @projeto = Projeto.find(params[:id])

    respond_to do |format|
      if @projeto.update_attributes(params[:projeto])
        format.html { redirect_to @projeto, notice: I18n.t("projetos.update.sucess") }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @projeto.errors, status: :unprocessable_entity }
      end
      redirect_to projetos_path
    return
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

end
