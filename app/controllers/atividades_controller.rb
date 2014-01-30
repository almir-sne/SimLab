class AtividadesController < ApplicationController
  load_and_authorize_resource

  def validacao
    hoje = Date.today
    if current_usuario.role == "admin"
      @projetos_opts = Projeto.select("nome, id").all(:order => "nome").collect { |p| [p.nome, p.id]  }
      @usuarios_opts = Usuario.select("nome, id").where(status: true).order(:nome).collect { |u| [u.nome, u.id]  }
    else
      @projetos_opts = current_usuario.projetos_coordenados.collect{ |p| [p.nome, p.id] }
      @usuarios_opts = current_usuario.equipe_coordenada.collect{ |u| [u.nome, u.id] }
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
    @atividades = Atividade.where(usuario_id: usuarios_ids, projeto_id: projetos_ids,
      aprovacao: aprovacoes_ids, data: @inicio..@fim).order(:data).group_by{|x| x.dia}
    @total_horas = ((@atividades.values.flatten.collect{|atividade| atividade.duracao}.sum.to_f)/3600).round(2)
  end

  def aprovar
    @user = current_user
    @user ||= current_usuario
    @atividade = Atividade.find params[:atividade_id]
    if @atividade.aprovacao.to_s == params[:aprovacao]
      @atividade.aprovacao = nil
    else
      @atividade.aprovacao = params[:aprovacao]
    end
    reg = Registro.new(autor_id: @user.id, atividade_id: @atividade.id)
    reg.transforma_hash_em_modificacao @atividade.changes
    @atividade.save and reg.save
    respond_to do |format|
      format.js
    end
  end

  def mensagens
    user = current_usuario
    user ||= current_user
    @atividade = Atividade.find params[:atividade_id]
    @atividade.mensagens.where{autor_id != my{user}.id}.update_all visto: true
    respond_to do |format|
      format.js
    end
  end

  def enviar_mensagem
    user = current_usuario
    user ||= current_user
    Atividade.find(params[:atividade_id]).update_attribute :avaliador_id, user.id
    mensagem = Mensagem.new(
      atividade_id: params[:atividade_id],
      conteudo: params[:mensagem],
      autor_id: user.id
    )
    if mensagem.save
      flash[:notice] = I18n.t("mensagem.create.success")
    else
      flash[:notice] = I18n.t("mensagem.create.failure")
    end
  end

end
