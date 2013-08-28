class UsuariosController < ApplicationController
  before_filter :authenticate_usuario!
  load_and_authorize_resource

  def index
    authorize! :see, Usuario
    @status = params[:status]
    unless @status.blank? or @status == "Todos"
      @users = Usuario.where(:status => @status == "true").order(:nome)
    else
      @users = Usuario.all(:order => :nome)
      @status = "Todos"
    end
    @status_list = ["Todos", ["Ativo", true], ["Inativo", false]]
    @user ||= Usuario.new
  end

  def custom_create
    authorize! :create, Usuario
    create
  end

  def create
    authorize! :create, Usuario
    @user = Usuario.new(params[:usuario])
    if @user.save
      flash[:notice] = I18n.t("devise.registrations.signed_up_another")
    else
      Rails.logger.info(@user.errors.messages.inspect)
      flash[:notice] = I18n.t("usuario.create.failure")
    end
    redirect_to usuarios_path
  end

  def edit
    authorize! :update, Usuario
    @user = Usuario.find(params[:id])
    @user.telefones.build if @user.telefones.blank?
    @user.contas.build if @user.contas.blank?
    @user.create_address if @user.address.blank?
    @user.contratos.build if @user.contratos.blank?
  end

  def update
    authorize! :update, Usuario
    @user = Usuario.find(params[:id])
    if @user.update_attributes(params[:usuario])
      flash[:notice] = "Usuário atualizado com sucesso"
      redirect_to edit_usuario_path(@user)
    else
      flash[:notice] = "Erro durante atualização de cadastro"
      render :action => 'edit'
    end
    
  end

  def destroy
    authorize! :destroy, Usuario
    @user = Usuario.find(params[:id])
    if @user.destroy
      flash[:notice] = I18n.t("usuario.delete.sucess")
    end
    redirect_to :back
  end

end
