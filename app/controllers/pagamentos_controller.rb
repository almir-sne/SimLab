class PagamentosController < ApplicationController
  load_and_authorize_resource

  def index
    @usuarios = Usuario.order(:nome)
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
    @periodos = contratos.map{|contrato| [contrato, contrato.periodos]}
    @total    = Pagamento.where(usuario_id: @usuario.id).sum :valor
    @media    = @periodos.blank? ? 0 : @total / @periodos.flatten.reject{|x| x.class == Contrato}.size
  end

  def listar
    if can? :manage, Pagamento
      @usuario = Usuario.find params[:usuario_id]
    else
      @usuario = current_usuario
    end
    @periodo    = params[:inicio].to_date .. params[:fim].to_date
    @pagamentos = Pagamento.periodos(@periodo).where(usuario_id: params[:usuario_id])
    @pagamento  = Pagamento.new
  end

  def create
    pagamento = Pagamento.new(params[:pagamento])
    if pagamento.update_attributes(params[:pagamento])
      flash[:notice] = I18n.t("pagamento.create.success")
    else
      flash[:alert] = I18n.t("pagamento.create.failure")
    end
    redirect_to :back
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
