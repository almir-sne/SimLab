class CartoesController < ApplicationController
  load_and_authorize_resource
  def index
    selects
    #TODO: Refatoração, filtro e scopes para cartao
    cartoes = Atividade.joins(:cartao).ano(Date.today.year).where{cartao.trello_id != nil}.
      order("data desc").pluck("cartoes.id").uniq
    @cartoes = cartoes.collect {|id| Cartao.find id}
  end

  def filtrar
    selects
    @dia        = params[:dia].to_i
    @mes        = params[:mes].to_i
    @ano        = params[:ano].to_i
    @usuario    = params[:usuario_id].to_i
    @projeto    = params[:projeto_id].to_i
    @tag        = params[:tag_id].to_i
    @cartao_pai = params[:cartao_pai].to_i

    cartoes = Atividade.joins(:cartao).ano(@ano).mes(@mes).dia(@dia).projeto(@projeto).
      usuario(@usuario).cartoes_tagados(@tag).where{cartao.trello_id != nil}.
      cartoes_filhos(@cartao_pai).order("data desc").pluck("cartoes.id").uniq
    @cartoes = cartoes.collect {|id| Cartao.find id}
    render :index
  end

  def show
    @cartao = Cartao.find_by(id: params[:id])
    @atividades = Atividade.joins(:cartao).where(cartao: @cartao)
  end

  def edit
    @cartao = Cartao.find_by(id: params[:id])
    @boards = current_user.boards.pluck(:board_id).uniq
  end

  def find_or_create
    cartao = Cartao.find_or_create_by(trello_id: params[:trello_id])
    redirect_to edit_cartao_path(cartao)
  end

  def update
    @cartao = Cartao.find(params[:id])
    respond_to do |format|
      if @cartao.update_attributes cartao_params
        format.js
      else
        format.html { render action: "edit" }
        format.json { render json: @cartao.errors, status: :unprocessable_entity }
      end
    end
  end

  def dados
    c = Cartao.find_by trello_id: params[:trello_id]
    if !params[:tags].blank? and params[:merge_tags] == "true"
      c.tags = (c.tags + params[:tags].collect{|t| Tag.find_or_create_by nome: t.gsub(/[\[\]]/, "")}).uniq
    end
    if c
      render json: {horas: "%.1f" % (c.horas_trabalhadas/3600), estimativa: c.estimativa,
        tags: c.tags.pluck(:nome), pai: c.pai.try(:trello_id), filhos: c.filhos.pluck(:trello_id),
        horas_filhos: c.horas_filhos}
    else
      render json: :erro
    end
  end

  def tags
    if params[:term]
      tags = Tag.where(["nome like ?", "%#{params[:term]}%"]).pluck(:nome)
      if tags.blank?
        render json: :erro
      else
        render json: tags
      end
    else
      render json: :erro
    end
  end

  private
  def cartao_params
    params.require(:cartao).permit(:tags_string, :pai_trello_id, {:filhos_array => []})
  end

  def selects
    @usuarios = [["Usuários - Todos", -1]] + Usuario.order(:nome).collect { |p| [p.nome, p.id] }
    @projetos = [["Projetos - Todos", -1]] + Projeto.order(:nome).collect { |p| [p.nome, p.id] }
    @dias     = [["Dias - Todos", -1]] + (1..31).to_a
    @anos     = [["Anos - Todos", -1]] + (2012..Date.today.year).to_a
    @meses    = [["Meses - Todos", -1]] + (1..12).collect {|mes| [t("date.month_names")[mes], mes]}
    @tags     = [["Tags - Todos", -1]] + Tag.order(:nome).collect { |p| [p.nome, p.id] }

    cartoes_pais =  Cartao.where(id: Cartao.where{pai_id != nil}.select(:pai_id))
    @cartoes_pais = cartoes_pais.collect { |p| p.id }
    @cartoes_pais_trello_ids = cartoes_pais.collect { |p| p.trello_id }
  end
end
