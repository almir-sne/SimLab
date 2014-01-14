class ProjetosController < ApplicationController
  before_action :authenticate_usuario!

  # GET /projetos
  # GET /projetos.json
  def index
    if params["tipo"] == "TODOS" || params["tipo"].nil?
      @tipo = "TODOS"
      if current_usuario.role == "admin"
        @projetos = Projeto.where(:super_projeto_id => nil).order(:nome).
          map{|superP| [superP, superP.sub_projetos.sort{|a,b| a.nome <=> b.nome}]}
      elsif current_usuario.role == "diretor"
        @projetos = current_usuario.projetos_coordenados.map{|proj| proj.super_projeto.nil? ? proj : proj.super_projeto}.uniq.
          map{|superP| [superP, superP.sub_projetos.where(:id => current_usuario.projetos_coordenados.
            map{|z| z.id})]}
      else
        @projetos = current_usuario.projetos.map{|proj| proj.super_projeto.nil? ? proj : proj.super_projeto}.uniq.
          map{|superP| [superP, superP.sub_projetos.where(:id => current_usuario.projetos.
            map{|z| z.id})]}
      end
    elsif params["tipo"] == "sub_projetos"
      @tipo = "sub_projetos"
      if current_usuario.role == "admin"
        @projetos = Projeto.all.select{|proj| !proj.super_projeto.nil?}.map{|sub| [sub,[]]}
      else
        @projetos = current_usuario.projetos_coordenados.
          select{|proj| !proj.super_projeto.nil?}.map{|sub| [sub,[]]}
      end
    elsif params["tipo"] == "super_projetos"
      @tipo = "super_projetos"
      if current_usuario.role == "admin"
        @projetos = Projeto.all.select{|proj| proj.super_projeto.nil?}.map{|sub| [sub,[]]}
      else
        @projetos = current_usuario.projetos_coordenados.
          select{|proj| proj.super_projeto.nil?}.map{|sup| [sup,[]]}
      end
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
    authorize! :read, Projeto
    @projeto = Projeto.find(params[:id])
    @filhos_for_select  = Projeto.all.sort{ |projeto|
      @projeto.sub_projetos.include?(projeto) ? -1 : 1}.
        map{|filho| [filho.nome, filho.id]}
    @pais_for_select = Projeto.find_all_by_super_projeto_id(nil).
      sort{|a, b| a.nome <=> b.nome}.
        map{|proj| [proj.nome, proj.id]}
    @eh_super_projeto = @projeto.super_projeto.blank?
    @usuarios = Usuario.all.order(nome: :asc)
    @hoje = Date.today
    @equipe = @projeto.usuarios.pluck(:nome).sort
    @inicio = params[:inicio].try(:to_date) || @hoje.beginning_of_month
    @fim = params[:fim].try(:to_date) || @hoje.end_of_month
    @ausencias = Ausencia.joins(:dia).where(dia: {data: @inicio..@fim}, projeto_id: @projeto.id).group_by{|x| x.dia.data}
    @atividades = Atividade.joins(:dia).where(dia: {data: @inicio..@fim}, projeto_id: @projeto.id).group_by{|x| x.dia.data}
  end

  # POST /projetos
  # POST /projetos.json
  def create
    authorize! :create, Projeto
    @projeto = Projeto.new(projetos_params)
    if @projeto.save
      Workon.new(usuario: current_user, projeto: @projeto, permissao: Permissao.find_by(nome: "admin")).save
      redirect_to projetos_path, notice: I18n.t("projetos.create.success")
    else
      puts @projeto.errors
      flash[:errors] = I18n.t("projetos.create.failure")
      redirect_to projetos_path
    end
  end

  # PATCH /projetos/1
  # PATCH /projetos/1.json
  def update
    authorize! :create, Projeto
    @projeto = Projeto.find(params[:id])
    boards = @projeto.boards.to_a
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
      debugger
      b.destroy
    end
    #lidar com subprojetos
    failure = false
    if params[:super_projeto] == "true"
      projetos_params.except! :super_projeto_id
      subprojetos = params[:sub_projetos]
      subprojetos.each do |index, sub|
        subprojeto = Projeto.find(sub["id"].to_i)
        if sub["filho"].nil? && subprojeto.super_projeto_id == @projeto.id
          failure ||= !(subprojeto.update_attribute :super_projeto_id, nil)
        elsif !(sub["filho"].nil?)
          failure ||= !(subprojeto.update_attribute :super_projeto_id, @projeto.id)
        end
      end
      @projeto.update_attribute :super_projeto_id, nil
    else
      @projeto.sub_projetos.each{|sub| sub.update_attribute :super_projeto_id, nil}
    end
    failure ||= !(@projeto.update_attributes projetos_params)
    respond_to do |format|
      if !failure
        format.html { redirect_to edit_projeto_path(@projeto), notice: I18n.t("projetos.update.success") }
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

  private

  def projetos_params
    params.require(:projeto).permit(:data_de_inicio, :descricao, :nome, :super_projeto_id,
      workons_attributes: [:id, :usuario_id, :_destroy, :permissao_id], sub_projetos: [:id, :filho])
  end

end
