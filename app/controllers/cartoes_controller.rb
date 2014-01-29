class CartoesController < ApplicationController
  load_and_authorize_resource
  def index
    hoje = Date.today()
    @usuario     = params[:usuario_id].blank? ? params[:usuario_id] = -1 : params[:usuario_id].to_i
    @usuarios    = [["Usuários - Todos", -1]] + Usuario.order(:nome).collect { |p| [p.nome, p.id]  }
    @projeto     = params[:projeto_id].blank? ? params[:projeto_id] = -1 : params[:projeto_id].to_i
    @projetos    = [["Projetos - Todos", -1]] + Projeto.order(:nome).collect { |p| [p.nome, p.id]  }
    @dia         = params[:dia].blank? ? params[:dia] = -1 : params[:dia].to_i
    @dias        = [["Dias - Todos", -1]] + (1..31).to_a
    @ano         = params[:ano].blank? ? params[:ano] = hoje.year : params[:ano].to_i
    @anos        = [["Anos - Todos", -1]] + (2012..hoje.year).to_a
    @mes         = params[:mes].blank? ? params[:mes] = -1 : params[:mes].to_i
    @meses       = [["Meses - Todos", -1]] + (1..12).collect {|mes| [t("date.month_names")[mes], mes]}

    cartoes = Atividade.joins(:cartao).ano(@ano).mes(@mes).dia(@dia).projeto(@projeto).
      usuario(@usuario).where{cartao.trello_id != nil}.order("data desc").pluck("cartoes.trello_id").uniq

    @stats = cartoes.collect {|id| {
        cartao_id: id,
        horas: Cartao.horas_trabalhadas_format(id),
        num_atividades: Atividade.joins(:cartao).where(cartao: {trello_id: id}).count
      }}
  end

  def show
    @atividades = Atividade.joins(:cartao).where(cartao: {trello_id: params[:id]})
    @cartao_id = params[:id]
  end

  def edit

  end
  
  def atualizar_trello
    Cartao.order(:updated_at).pluck(:trello_id).each { |c| Cartao.update_on_trello(params[:key], params[:token], c) }
  end
end
