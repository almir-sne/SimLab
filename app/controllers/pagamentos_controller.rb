class PagamentosController < ApplicationController
  load_and_authorize_resource

  def index
    hoje = Date.today
    @usuario  = params[:usuario_id].blank? ? params[:usuario_id] = -1 : params[:usuario_id].to_i
    @users    = [["Usuários - Todos", -1]] + Usuario.order(:nome).collect { |p| [p.nome, p.id]  }
    @dia      = params[:dia].blank? ? params[:dia] = -1 : params[:dia].to_i
    @dias     = [["Dias - Todos", -1]] + (1..31).to_a
    @ano      = params[:ano].blank? ? params[:ano] = hoje.year : params[:ano].to_i
    @anos     = [["Anos - Todos", -1]] + (2012..hoje.year).to_a
    @mes      = params[:mes].blank? ? params[:mes] = -1 : params[:mes].to_i
    @meses    = [["Meses - Todos", -1]] + (1..12).collect {|mes| [ t("date.month_names")[mes], mes]}
    @usuarios_nomes = Usuario.order(:nome)
    user = @usuario if @usuario > 0
    @pagamentos = Pagamento.ano(@ano).mes(@mes).dia(@dia).usuario(user).order(:data).
      paginate(:page => params[:page], :per_page => 15)
  end

  def periodos
    if can? :manage, Pagamento
      @usuario = Usuario.find params[:usuario_id]
    else
      @usuario = current_usuario
    end
    contratos = Contrato.where(:usuario_id => @usuario.id)
    if contratos.all?{|contrato| contrato.dia_inicio_periodo.nil?}
      return redirect_to :back, alert: I18n.t("contrato.dia_inicio_periodo.nil")
    end
    @pagamento  = Pagamento.new
    @periodos   = contratos.map{|contrato| [contrato, contrato.periodos]}
    @pagamentos = Pagamento.where(usuario_id: @usuario.id)
    @total      = @pagamentos.sum :valor
    @media      = @periodos.blank? ? 0 : @total / @periodos.flatten.reject{|x| x.class == Contrato}.size
  end

  def listar
    if can? :manage, Pagamento
      @usuario = Usuario.find params[:usuario_id]
    else
      @usuario = current_usuario
    end
    @periodo    = params[:inicio].to_date .. params[:fim].to_date
    @pagamentos = Pagamento.periodos(@periodo).where(usuario_id: params[:usuario_id])
    @pagamentos = @pagamentos.map{|pag| [pag, Anexo.where(:pagamento_id => pag.id).first]}
    @pagamento  = Pagamento.new
  end

  def create
    pagamento = Pagamento.new(params[:pagamento])
    if pagamento.update_attributes(params[:pagamento])
      flash[:notice] = I18n.t("pagamento.create.success")
    else
      flash[:alert] = I18n.t("pagamento.create.failure")
    end
    unless params[:comprovante].nil?
      Anexo.new(
        :arquivo => params[:comprovante],
        :tipo => "holerite",
        :data => params[:pagamento][:data],
        :usuario_id => params[:pagamento][:usuario_id],
        :pagamento_id => pagamento.id
      ).save
    end
    redirect_to :back
  end

  def download
    anexo = Anexo.find params[:id]
    path = "/#{anexo.arquivo}"
    send_file path, :x_sendfile=>true
  end

  def destroy
    authorize! :destroy, Usuario
    pagamento = Pagamento.find(params[:id])
    if pagamento.destroy
      flash[:notice] = I18n.t("pagamento.delete.success")
    end
    redirect_to :back
  end
end
