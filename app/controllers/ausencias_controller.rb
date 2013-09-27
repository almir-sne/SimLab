class AusenciasController < ApplicationController
  load_and_authorize_resource

  def destroy
    ausencia = Ausencia.find params[:id]
    ausencia.destroy
    redirect_to :back
  end
  
  def create
    ausencia = Ausencia.find_by_id(params[:dia_id])
    if ausencia.blank?
      ausencia = Ausencia.new
    end
    ausencia.update_attributes(params[:ausencia])
    ausencia.usuario_id = params[:user_id]
    ausencia.mes_id = params[:mes]
    if ausencia.save
      flash[:notice] = I18n.t("banco_de_horas.create.sucess")
    else
      flash[:error] = I18n.t("banco_de_horas.create.failure")
    end
    redirect_to banco_de_horas_path(:month => ausencia.mes.numero,
      :year => ausencia.mes.ano, :user => ausencia.usuario.id)
  end
  
  def index
    authorize! :update, :validations
    #filtrar as ausencias
    hoje = Date.today
    meses_id = Mes.find_all_by_numero_and_ano(meses_selecionados(params[:mes], hoje), anos_selecionados(params[:ano], hoje)).collect{|month| month.id }
    dias_selecionados  = (params[:dia].nil? || params[:dia] == "-1") ? (1..31).to_a : params[:dia]
    @ausencias = @ausencias.where(
      :abonada => nil,
      :mes_id => meses_id,
      :usuario_id => usuarios_selecionados(params[:usuario_id]),
      :dia => dias_selecionados
    )
    #popular os combobox
    if current_usuario.role == "admin"
      equipe = Usuario.all(:order => "nome")
      projetos = Projeto.all(:order => "nome")
    else
      projetos = current_usuario.projetos_coordenados
      equipe = current_usuario.equipe(projetos)
    end
    @usuario     = params[:usuario_id].blank? ? params[:usuario_id] = -1 : params[:usuario_id]
    @usuarios    = [["Usuários - Todos", -1]] + equipe.collect { |p| [p.nome, p.id]  }
    @projeto     = params[:projeto_id].blank? ? params[:projeto_id] = -1 : params[:projeto_id]
    @projetos    = [["Projetos - Todos", -1]] + projetos.collect { |p| [p.nome, p.id]  }
    @dia         = params[:dia].blank? ? params[:dia] = -1 : params[:dia]
    @dias        = [["Dias - Todos", -1]] + (1..31).to_a
    @ano         = params[:ano].blank? ? params[:ano] = hoje.year : params[:ano]
    @anos        = [["Anos - Todos", -1]] + (2012..2014).to_a
    @mes         = params[:mes].blank? ? params[:mes] = hoje.month : params[:mes]
    @meses       = [["Meses - Todos", -1]] + (1..12).collect {|mes| [ t("date.month_names")[mes], mes]}
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
    flash[:notice] = I18n.t("ausencia.validation.sucess")
    redirect_to ausencias_path
  end
end
