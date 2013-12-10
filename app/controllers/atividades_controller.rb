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
      @projetos_opts = Projeto.select("nome, id").all(:order => "nome").collect { |p| [p.nome, p.id]  }
      @usuarios_opts = Usuario.select("nome, id").all(:order => "nome").collect { |u| [u.nome, u.id]  }
    else
      @projetos_opts = current_usuario.projetos_coordenados.collect{ |p| [p.nome, p.id] }
      @usuarios_opts = current_usuario.equipe_coordenada_por_projetos(projetos).collect{ |u| [u.nome, u.id] }
    end
    @aprovacoes_opts  = [["Aprovadas", 'true'],["Reprovadas", 'false'],["Não Vistas", 'nil']]
    if params[:commit] == "limpar"
      usuarios_ids = @usuarios_opts.collect{|u| u[1]}
      projetos_ids = @projetos_opts.collect{|u| u[1]}
      @aprovacao = [true, false, nil]
      @inicio = hoje.at_beginning_of_month
      @fim = hoje.at_end_of_month
      @aprovacoes_selected = @projetos_selected = @usuarios_selected = Array.new
    else
      if params[:usuario_id].nil?
        if cookies[:usuario_id].blank? or cookies[:usuario_id].class == String
          usuarios_ids = @usuarios_opts.collect{|u| u[1]}
          @usuarios_selected = Array.new
        else
          @usuarios_selected = usuarios_ids = cookies[:usuario_id].collect{|id| id.to_i}
        end
      else
        @usuarios_selected = usuarios_ids = params[:usuario_id].collect{|id| id.to_i}
      end
      if params[:projeto_id].nil?
        if cookies[:projeto_id].blank? or cookies[:projeto_id].class == String
          projetos_ids = @projetos_opts.collect{|u| u[1]}
          @projetos_selected = Array.new
        else
          @projetos_selected = projetos_ids = cookies[:projeto_id].collect{|id| id.to_i}
        end
      else
        @projetos_selected = projetos_ids = params[:projeto_id].collect{|id| id.to_i}
      end
      if params[:aprovacao].nil?
        if cookies[:aprovacao].blank? or cookies[:aprovacao].class == String
          aprovacoes_ids = [true, false, nil]
          @aprovacoes_selected = Array.new
        else
          debugger
          @aprovacoes_selected = aprovacoes_ids = cookies[:aprovacao].collect{|id| to_boolean(id) }
        end
      else
        @aprovacoes_selected = aprovacoes_ids = params[:aprovacao].collect{|id| to_boolean(id) }
      end
      @inicio = date_from_object(params[:inicio] || cookies[:inicio] || hoje.at_beginning_of_month)
      @fim = date_from_object(params[:fim] || cookies[:fim] || hoje.at_end_of_month)
    end
    cookies[:usuario_id] = @usuarios_selected
    cookies[:projeto_id] = @projetos_selected
    cookies[:aprovacao] = @aprovacoes_selected
    cookies[:fim] = @fim
    cookies[:inicio] = @inicio
    @atividades = Atividade.where(usuario_id: usuarios_ids, projeto_id: projetos_ids, aprovacao: aprovacoes_ids, data: @inicio..@fim).order(:data).group_by{|x| x.dia}
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
    @atividade.mensagens.where{autor_id != current_usuario.id}.update_all visto: true
    respond_to do |format|
      format.js
    end
  end

  def enviar_mensagem
    mensagem = Mensagem.new(
      atividade_id: params[:atividade_id],
      conteudo: params[:mensagem],
      autor_id: current_usuario.id
    )
    if mensagem.save
      flash[:notice] = I18n.t("mensagem.create.success")
    else
      flash[:notice] = I18n.t("mensagem.create.failure")
    end
  end

  def date_from_object(obj)
    if obj.class == Date
      obj
    elsif obj.class == String
      Date.parse(obj)
    else
      if Date.valid_date?(obj[:year].to_i, obj[:month].to_i, obj[:day].to_i)
        Date.new(obj[:year].to_i, obj[:month].to_i, obj[:day].to_i)
      else
        Date.new(obj[:year].to_i, obj[:month].to_i, 1).at_end_of_month
      end
    end
  end
end
