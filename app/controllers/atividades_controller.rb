class AtividadesController < ApplicationController
  load_and_authorize_resource

  def validacao
    hoje = Date.today
    if current_usuario.role == "admin"
      @projetos_opts = Projeto.ativos.order(:nome).pluck(:nome, :id)
      @usuarios_opts = Usuario.where(status: true).order(:nome).pluck(:nome, :id)
    else
      @projetos_opts = current_usuario.projetos_coordenados.pluck(:nome, :id)
      @usuarios_opts = current_usuario.equipe_coordenada.pluck(:nome, :id)
    end
    @aprovacoes_opts  = [["Aprovadas", 'true'],["Reprovadas", 'false'],["Não Vistas", 'nil']]

    @usuarios_selected = session[:usuario_id]
    @projetos_selected = session[:projeto_id]
    @aprovacoes_selected = session[:aprovacao]
    @fim = date_from_object(session[:fim] || hoje.at_end_of_month)
    @inicio = date_from_object(session[:inicio] || hoje.at_beginning_of_month)

    usuarios_ids = @usuarios_selected || @usuarios_opts.collect{|u| u[1]}
    projetos_ids = @projetos_selected || @projetos_opts.collect{|u| u[1]}
    @atividades = Atividade.where(usuario_id: usuarios_ids, projeto_id: projetos_ids,
      data: @inicio..@fim).aprovacao(@aprovacoes_selected.to_a.collect{|x| to_boolean x}).order(:data)
    @total_horas = (@atividades.sum(:duracao)/3600).round(2)
  end

  def filtrar
    if params[:commit] == "limpar"
      session[:usuario_id] = nil
      session[:projeto_id] = nil
      session[:fim] = nil
      session[:inicio] = nil
    else
      session[:usuario_id] = params[:usuario_id]
      session[:projeto_id] = params[:projeto_id]
      session[:aprovacao] = params[:aprovacao]
      session[:fim] = params[:fim]
      session[:inicio] = params[:inicio]
    end
    redirect_to validacao_atividades_path
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
    reg.atividade_mudanças_em_modificação @atividade.changes
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
    @projetos = usuario.meus_projetos_array
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
    mudanças = @atividade.changes
    unless mudanças.blank?
      registro_atividades = Registro.new(autor_id: @atividade.usuario.id, atividade_id: @atividade.id)
      registro_atividades.atividade_mudanças_em_modificação mudanças
      registro_atividades.save
    end
    mudanças = @atividade.pares.map{|par| par.changes}
    mudanças.each do |mudança|
      unless mudança.blank?
        registro_par = Registro.new(autor_id: @atividade.usuario.id, atividade_id: @atividade.id)
        puts"|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
        puts registro_par.inspect
        puts"|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
        registro_par.par_mudança_em_modificação mudança
        registro_par.save
      end
    end
    @error_message = ""
    if (@atividade.projeto.tags_obrigatorio and @atividade.cartao.tags.blank?)
      @error_message += "O projeto selecionado exige que o cartão tenha tags. "
    end
    if (@atividade.projeto.pai_obrigatorio and @atividade.cartao.pai.blank?)
      @error_message += "O projeto selecionado exige que o cartão tenha pai. "
    end

    if @error_message.blank?
      unless @atividade.changes.blank?
        reg = Registro.new(autor_id: @atividade.usuario.id, atividade_id: @atividade.id)
        reg.transforma_hash_em_modificacao @atividade.changes
        reg.save
      end
      @atividade.save
    end

    respond_to do |format|
      format.js
    end
  end
end

private
def atividade_params
  params.require(:atividade).permit(:projeto_id , :minutos, :trello_id, :observacao, pares_attributes: [:id, :par_id, :minutos, :_destroy])
end
