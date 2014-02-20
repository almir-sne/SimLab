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
      @inicio = hoje.at_beginning_of_month
      @fim = hoje.at_end_of_month
      @projetos_selected = @usuarios_selected = Array.new
      @aprovacoes_selected = ['nil']
    else
      if params[:usuario_id].nil?
        if session[:usuario_id].blank?
          usuarios_ids = @usuarios_opts.collect{|u| u[1]}
          @usuarios_selected = Array.new
        else
          @usuarios_selected = usuarios_ids = session[:usuario_id].collect{|id| id.to_i}
        end
      else
        @usuarios_selected = usuarios_ids = params[:usuario_id].collect{|id| id.to_i}
      end
      if params[:projeto_id].nil?
        if session[:projeto_id].blank?
          projetos_ids = @projetos_opts.collect{|u| u[1]}
          @projetos_selected = Array.new
        else
          @projetos_selected = projetos_ids = session[:projeto_id].collect{|id| id.to_i}
        end
      else
        @projetos_selected = projetos_ids = params[:projeto_id].collect{|id| id.to_i}
      end
      if params[:aprovacao].nil?
        if session[:aprovacao].blank?
          @aprovacoes_selected = ['nil']
        else
          @aprovacoes_selected = session[:aprovacao]
        end
      else
        @aprovacoes_selected = params[:aprovacao]
      end
      @inicio = date_from_object(params[:inicio] || session[:inicio] || hoje.at_beginning_of_month)
      @fim = date_from_object(params[:fim] || session[:fim] || hoje.at_end_of_month)
    end
    session[:usuario_id] = @usuarios_selected
    session[:projeto_id] = @projetos_selected
    session[:aprovacao] = @aprovacoes_selected
    session[:fim] = @fim
    session[:inicio] = @inicio
    @atividades = Atividade.where(usuario_id: usuarios_ids, projeto_id: projetos_ids,
      aprovacao: @aprovacoes_selected.collect{|x| to_boolean x}, data: @inicio..@fim).order(:data)
    @total_horas = (@atividades.sum(:duracao)/3600).round(2)
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

  def ajax_form
    dia = Dia.find params[:dia_id]
    usuario = dia.usuario
    @projetos = usuario.meus_projetos
    @atividade = Atividade.new(dia_id: dia.id, data: dia.data, usuario_id: usuario.id)
    @atividade.trello_id = params[:trello_id]
    @atividade.projeto_id = @projetos.first[1]
    @atividade.save
    @equipe = usuario.equipe.collect{|u| [u.nome, u.id]}
    respond_to do |format|
      format.js
    end
  end

  def destroy
    atividade = Atividade.find(params[:id])
    @atividade_id = atividade.id
    atividade.destroy

    respond_to do |format|
      format.js
    end
  end

  def update
    @atividade = Atividade.find(params[:id])
    @atividade.assign_attributes atividade_params
    reg = Registro.new(autor_id: @atividade.usuario.id, atividade_id: @atividade.id)
    reg.transforma_hash_em_modificacao @atividade.changes
    respond_to do |format|
      if @atividade.save and reg.save
        format.js
      end
    end
  end

  private
  def atividade_params
    params.require(:atividade).permit(:projeto_id, :minutos, :trello_id, :observacao)
  end
end
