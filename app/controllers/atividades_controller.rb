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
    Cartao.order(:updated_at).pluck(:trello_id)..each { |c| Cartao.update_on_trello(params[:key], params[:token], c) }
  end
  
  def listar_atividades
    @atividades = Atividade.joins(:cartao).where(cartao: {trello_id: params[:cartao_id]})
    @cartao_id = params[:cartao_id]
  end
  
  def validar
    authorize! :update, :validations
    hoje = Date.today
    if current_usuario.role == "admin"
      equipe = Usuario.select("nome, id").all(:order => "nome")
      projetos = Projeto.select("nome, id").all(:order => "nome")
    else
      projetos = current_usuario.projetos_coordenados
      equipe = current_usuario.equipe_coordenada_por_projetos(projetos)
    end
    @usuario     = params[:usuario_id].blank? ? params[:usuario_id] = -1 : params[:usuario_id].to_i
    @usuarios    = [["Usuários - Todos", -1]] + equipe.collect { |p| [p.nome, p.id]  }
    @projeto     = params[:projeto_id].blank? ? params[:projeto_id] = -1 : params[:projeto_id].to_i
    @projetos    = [["Projetos - Todos", -1]] + projetos.collect { |p| [p.nome, p.id]  }
    @dia         = params[:dia].blank? ? params[:dia] = -1 : params[:dia].to_i
    @dias        = [["Dias - Todos", -1]] + (1..31).to_a
    @ano         = params[:ano].blank? ? params[:ano] = hoje.year : params[:ano].to_i
    @anos        = [["Anos - Todos", -1]] + (2012..2014).to_a
    @mes         = params[:mes].blank? ? params[:mes] = hoje.month : params[:mes].to_i
    @meses       = [["Meses - Todos", -1]] + (1..12).collect {|mes| [ t("date.month_names")[mes], mes]}
    @aprovacoes  = [["Aprovações - Todas",-1],["Aprovadas",1],["Reprovadas",0],["Não Vistas",3]]
    @aprovacao   = params[:aprovacao].blank? ? params[:aprovacao] = 3 : params[:aprovacao].to_i
    #filtrar as atividades
    @atividades = Atividade.usuario(@usuario).projeto(@projeto).dia(@dia).ano(@ano).mes(@mes).aprovacao(@aprovacao)
    @total_horas = ((@atividades.collect{|atividade| atividade.duracao}.sum.to_f)/3600).round(2)
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
    @usuarios    = [["Selecione envolvido", 0]] + equipe.collect { |p| [p.nome, p.id]  }
    @projeto     = params[:projeto_id].to_i
    @projetos    = [["Selecione Projeto", 0]] + projetos.collect { |p| [p.nome, p.id]  }
    @dia         = params[:dia].to_i
    @dias        = [["Dias - Todos", 0]] + (1..31).to_a
    @ano         = params[:ano].blank? ? params[:ano] = hoje.year : params[:ano].to_i
    @anos        = [["Anos - Todos", 0]] + (2012..hoje.year).to_a
    @mes         = params[:mes].blank? ? params[:mes] = hoje.month : params[:mes].to_i
    @meses       = [["Meses - Todos", 0]] + (1..12).collect {|mes| [ t("date.month_names")[mes], mes]}
    @aprovacoes  = [["Selecione Status", nil], ["Todas", 4], ["Aprovadas", 1],["Reprovadas", 0],["Não Vistas", 3]]
    @aprovacao   = params[:aprovacao].blank? ? params[:aprovacao] = 3 : params[:aprovacao].to_i
    #filtrar as atividades
    @atividades = Atividade.usuario(@usuario).projeto(@projeto).dia(@dia).ano(@ano).mes(@mes).aprovacao(@aprovacao)
    @total_horas = ((@atividades.collect{|atividade| atividade.duracao}.sum.to_f)/3600).round(2)
  end

  def mandar_validacao
    authorize! :update, :validations
    atividades = params[:atividades].try(:keys)
    atividades ||= []
    for i in atividades
      ativ = params[:atividades][i.to_str]
      Atividade.find(ativ["id"].to_i).update_attributes(
        :aprovacao => ativ["aprovacao"],
        :mensagem => ativ["mensagem"],
        :avaliador_id => current_user.id
      )
    end
    flash[:notice] = I18n.t("atividades.validation.success")
    redirect_to :back
  end
end
