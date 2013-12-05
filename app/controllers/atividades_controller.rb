class AtividadesController < ApplicationController
  load_and_authorize_resource

  def cartoes
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
      usuario(@usuario).where("trello_id is not null").order("data desc").pluck(:trello_id).uniq
    
    @stats = cartoes.collect {|id| {
        cartao_id: id,
        horas: Cartao.horas_trabalhadas_format(id),
        num_atividades: Atividade.joins(:cartao).where(cartao: {trello_id: id}).count
      }}
  end
  
  def atualizar_cartoes
    Cartao.order(:updated_at).pluck(:trello_id).each { |c| Cartao.update_on_trello(params[:key], params[:token], c) }
  end
  
  def listar_atividades
    @atividades = Atividade.joins(:cartao).where(cartao: {trello_id: params[:cartao_id]})
    @cartao_id = params[:cartao_id]
  end
  
  def validacao
    hoje = Date.today
    if current_usuario.role == "admin"
      equipe = Usuario.select("nome, id").all(:order => "nome")
      projetos = Projeto.select("nome, id").all(:order => "nome")
    else
      projetos = current_usuario.projetos_coordenados
      equipe = current_usuario.equipe_coordenada_por_projetos(projetos)
    end
    @usuario     = params[:usuario_id].to_i
    @usuarios    = [["Selecione Envolvido", 0]] + equipe.collect { |p| [p.nome, p.id]  }
    @projeto     = params[:projeto_id].to_i
    @projetos    = [["Selecione Projeto", 0]] + projetos.collect { |p| [p.nome, p.id]  }
    @aprovacoes  = [["Todas", 5], ["Aprovadas", 1],["Reprovadas", 0],["Não Vistas", 3]]
    @aprovacao   = params[:aprovacao].blank? ? 3 : params[:aprovacao].to_i
    
    if params[:data]
      data = params[:data].split(";")
      @mes = data[0].to_i
      @ano = data[1].to_i
    else
      @ano         = @ano = hoje.year
      @mes         = @mes = hoje.month
    end
    #filtrar as atividades
    @atividades = Atividade.usuario(@usuario).projeto(@projeto).ano(@ano).
      mes(@mes).aprovacao(@aprovacao).order(:data).group_by{|x| [x.usuario, x.dia]}
    @total_horas = ((@atividades.values.flatten.collect{|atividade| atividade.duracao}.sum.to_f)/3600).round(2)
  end
  
  def aprovar
    @atividade = Atividade.find params[:atividade_id]
    if @atividade.aprovacao.to_s == params[:aprovacao]
      @atividade.aprovacao = nil
    else
      @atividade.aprovacao = params[:aprovacao]
    end
    @atividade.save
    respond_to do |format|
      format.js
    end
  end
  
  def mensagens
    @atividade = Atividade.find params[:atividade_id]
    respond_to do |format|
      format.js
    end
  end
  
  def enviar_mensagem
    atividade = Atividade.find params[:atividade_id]
    atividade.mensagem = params[:mensagem]
    atividade.save
  end
end
