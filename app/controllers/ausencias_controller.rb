class AusenciasController < ApplicationController
  load_and_authorize_resource

  def destroy
    ausencia = Ausencia.find params[:id]
    ausencia.destroy
    redirect_to :back
  end

  def new
    #arrumar permissões? dá pra cadastrar ausência de outra pessoa desse jeito
    @usuario_id = params[:usuario_id]
    @data = params[:data]
    @tipo = params[:tipo]
  end

  def create
    ausencia = Ausencia.new
    ausencia.dia = Dia.find_or_create_by_data_and_usuario_id(Date.parse(params[:data]), params[:usuario_id].to_i)
    ausencia.update_attributes(params[:ausencia])
    data = ausencia.dia.data
    if ausencia.save
      flash[:notice] = I18n.t("ausencias.create.success")
    else
      flash[:error] = I18n.t("ausencias.create.failure")
    end
    unless params[:anexo].nil?
      Anexo.new(
        :arquivo => params[:anexo],
        :tipo => "atestado",
        :data => params[:data],
        :usuario_id => params[:usuario_id],
        :ausencia_id => ausencia.id
      ).save
    end
    redirect_to dias_path(data: params[:data], tipo: params[:tipo])
  end

  def index
    authorize! :update, :validations
    #filtrar as ausencias
    hoje = Date.today
    #popular os combobox
    if current_usuario.role == "admin"
      equipe = Usuario.all(:order => "nome")
      projetos = Projeto.all(:order => "nome")
    else
      projetos = current_usuario.projetos_coordenados
      equipe = current_usuario.equipe_coordenada
    end
    @usuario   = params[:usuario_id].blank? ? params[:usuario_id] = -1 : params[:usuario_id]
    @usuarios  = [["Usuários - Todos", -1]] + equipe.collect { |p| [p.nome, p.id]  }
    @projeto   = params[:projeto_id].blank? ? params[:projeto_id] = -1 : params[:projeto_id]
    @projetos  = [["Projetos - Todos", -1]] + projetos.collect { |p| [p.nome, p.id]  }
    @dia       = params[:dia].blank? ? params[:dia] = -1 : params[:dia]
    @dias      = [["Dias - Todos", -1]] + (1..31).to_a
    @ano       = params[:ano].blank? ? params[:ano] = hoje.year : params[:ano]
    @anos      = [["Anos - Todos", -1]] + (2012..2014).to_a
    @mes       = params[:mes].blank? ? params[:mes] = hoje.month : params[:mes]
    @meses     = [["Meses - Todos", -1]] + (1..12).collect {|mes| [ t("date.month_names")[mes], mes]}
    @ausencias = Ausencia.data(@ano.to_i, @mes.to_i, @dia.to_i).usuario(@usuario.to_i).aprovacao([false,nil])
  end

  def validar
    ausencias = params[:ausencias]
    ausencias.each do |id, a|
      ausencia =  Ausencia.find(a["id"])
      ausencia.update_attribute(:abonada, to_boolean(a[:abonada]))
      ausencia.update_attribute(:mensagem, a[:mensagem])
      ausencia.update_attribute(:avaliador_id, current_user.id)
      ausencia.update_attribute(:horas, a[:horas])
    end
    flash[:notice] = I18n.t("ausencia.validation.success")
    redirect_to ausencias_path
  end

  def ausencia
    @usuario = Usuario.where(id: params[:usuario_id]) || current_user
    @inicio = Date.parse params[:inicio]
    @fim = Date.parse params[:fim]
    @dias_periodo = dias_no_periodo(@inicio, @fim)
    if params[:id].nil?
      @ausencia =  Ausencia.new
    else
      @ausencia =  Ausencia.find(params[:id])
    end
    respond_to do |format|
      format.html
      format.js
    end
  end
end
