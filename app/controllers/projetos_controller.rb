class ProjetosController < ApplicationController
  before_filter :authenticate_usuario!

  # GET /projetos
  # GET /projetos.json
  def index
    authorize! :read, Projeto
    if current_usuario.role == "admin"
      @projetos = Projeto.where(:super_projeto_id => nil).order(:nome)
      @projetos = @projetos.map{|superP| [superP, superP.sub_projetos.sort{|a,b| a.nome <=> b.nome}]}.flatten
    else
      @projetos = current_usuario.projetos_coordenados.sort{|a,b| a.nome <=> b.nome}
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
    @filhos_for_select  = Projeto.all.sort{ |projeto|
      @projeto.sub_projetos.include?(projeto) ? -1 : 1}.
        map{|filho| [filho.nome, filho.id]}
    @eh_super_projeto = @projeto.super_projeto.blank?
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
    #lidar com boards
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
    #lidar com subprojetos
    failure = false
    if params[:super_projeto] == "true"
      params[:projeto].except! :super_projeto_id
      subprojetos = params[:sub_projetos]
      subprojetos.each do |index, sub|
        subprojeto = Projeto.find(sub["id"].to_i)
        if sub["filho"].nil? && subprojeto.super_projeto_id == @projeto.id
          failure ||= !(subprojeto.update_attribute :super_projeto_id, nil)
        elsif !(sub["filho"].nil?)
          failure ||= !(subprojeto.update_attribute :super_projeto_id, @projeto.id)
        end
      end
    end
    respond_to do |format|
    debugger
      if true
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
end
