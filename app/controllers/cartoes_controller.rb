class CartoesController < ApplicationController
  load_and_authorize_resource

  def estatisticas
    hoje = Date.today()
    @usuario  = params[:usuario_id].blank? ? params[:usuario_id] = -1 : params[:usuario_id].to_i
    @usuarios = [["Usuários - Todos", -1]] + Usuario.order(:nome).collect { |p| [p.nome, p.id]  }
    @projeto  = params[:projeto_id].blank? ? params[:projeto_id] = -1 : params[:projeto_id].to_i
    @projetos = [["Projetos - Todos", -1]] + Projeto.order(:nome).collect { |p| [p.nome, p.id]  }
    @dia      = params[:dia].blank? ? params[:dia] = -1 : params[:dia].to_i
    @dias     = [["Dias - Todos", -1]] + (1..31).to_a
    @ano      = params[:ano].blank? ? params[:ano] = hoje.year : params[:ano].to_i
    @anos     = [["Anos - Todos", -1]] + (2012..hoje.year).to_a
    @mes      = params[:mes].blank? ? params[:mes] = -1 : params[:mes].to_i
    @meses    = [["Meses - Todos", -1]] + (1..12).collect {|mes| [ t("date.month_names")[mes], mes]}
    atividade = {}
    atividade[:projeto_id] = @projeto if @projeto > 0
    atividade[:usuario_id] = @usuario if @usuario > 0
    cartoes = Cartao.joins(:atividade).group(:cartao_id).ano(@ano).mes(@mes).dia(@dia).
      atividade(atividade).order("cartoes.updated_at desc").pluck(:cartao_id)
    @stats = cartoes.collect {|id| {
        cartao_id: id,
        horas: Cartao.horas_trabalhadas_format(id),
        num_atividades: Cartao.where(cartao_id: id).count
      }}.paginate(:page => params[:page], :per_page => 30)
  end

  def atualizar_cartoes
    Cartao.group(:cartao_id).order("cartoes.updated_at desc").pluck(:cartao_id).each { |c| Cartao.update_on_trello(params[:key], params[:token], c) }
  end

  def atividades
    cartoes = Cartao.where(cartao_id: params[:cartao_id])
    @atividades = cartoes.collect{|cartao| cartao.atividade}
    @cartao_id = params[:cartao_id]
  end
end
