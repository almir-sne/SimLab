class ProjetosController < ApplicationController
  before_filter :authenticate_usuario!

  # GET /projetos
  # GET /projetos.json
  def index
    authorize! :read, Projeto
    if current_usuario.role == "admin"
      @projetos = Projeto.all(:order => :nome)
    else
      @projetos = current_usuario.projetos_coordenados.all(:order => :nome)
    end
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
    @usuarios = Usuario.order(:nome)
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
    boards = @projeto.boards
    unless params[:trello].blank?
      params[:trello].each do |id|
        repetido = false
        boards.each_with_index do |c, i|
          if id == c.board_id
            repetido = true
            boards.delete_at i
          end
        end
        unless repetido
          board = Board.new
          board.projeto = @projeto
          board.board_id = id
          board.save
        end
      end
    end
    boards.each do |b|
      b.destroy
    end
    respond_to do |format|
      if @projeto.update_attributes(params[:projeto])
        format.html { redirect_to edit_projeto_path(@projeto), notice: I18n.t("projetos.update.sucess") }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_projeto_path(@projeto), notice: I18n.t("projetos.update.failure") }
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
  
  def coordenadorform
    @workon = Workon.find(params[:wrkn_id])
    usuarios = Usuario.joins(:workons).where('usuarios.id != ? and workons.projeto_id = ?', @workon.usuario.id, @workon.projeto.id)
    @user_list = usuarios.collect { |u| [u.nome, u.id]  }
    respond_to do |format|
      format.html
      format.js
    end
  end
  
end
