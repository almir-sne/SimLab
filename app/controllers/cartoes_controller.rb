class CartoesController < ApplicationController
  load_and_authorize_resource
  def index
    hoje = Date.today()
    @usuario  = params[:usuario_id].blank? ? params[:usuario_id] = -1 : params[:usuario_id].to_i
    @usuarios = [["Usuários - Todos", -1]] + Usuario.order(:nome).collect { |p| [p.nome, p.id] }
    @projeto  = params[:projeto_id].blank? ? params[:projeto_id] = -1 : params[:projeto_id].to_i
    @projetos = [["Projetos - Todos", -1]] + Projeto.order(:nome).collect { |p| [p.nome, p.id] }
    @dia      = params[:dia].blank? ? params[:dia] = -1 : params[:dia].to_i
    @dias     = [["Dias - Todos", -1]] + (1..31).to_a
    @ano      = params[:ano].blank? ? params[:ano] = hoje.year : params[:ano].to_i
    @anos     = [["Anos - Todos", -1]] + (2012..hoje.year).to_a
    @mes      = params[:mes].blank? ? params[:mes] = -1 : params[:mes].to_i
    @meses    = [["Meses - Todos", -1]] + (1..12).collect {|mes| [t("date.month_names")[mes], mes]}
    @tags     = [["Tags - Todos", -1]] + Tag.order(:nome).collect { |p| [p.nome, p.id] }
    @tag      = params[:tag_id].blank? ? params[:tag_id] = -1 : params[:tag_id].to_i

    #TODO: Refatoração, filtro e scopes para cartao
    cartoes = Atividade.joins(:cartao).ano(@ano).mes(@mes).dia(@dia).projeto(@projeto).
      usuario(@usuario).cartoes_tagados(@tag).where{cartao.trello_id != nil}.order("data desc").pluck("cartoes.id").uniq
    @cartoes = cartoes.collect {|id| Cartao.find id}
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
        artao.update_on_trello(params[:key], params[:token], @cartao.trello_id)
        format.html { redirect_to edit_cartao_path(id: @cartao.trello_id), notice: 'Cartão atualizado com sucesso.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cartao.errors, status: :unprocessable_entity }
      end
    end
  end

  def atualizar_trello
    Cartao.order(:updated_at).pluck(:trello_id).each { |c| Cartao.update_on_trello(params[:key], params[:token], c) }
  end

  def cartao_params
    params.require(:cartao).permit(:tags_string, :pai_trello_id)
  end
end
