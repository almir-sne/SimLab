class UsuariosController < ApplicationController

  def index
    @users = Usuario.all
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
      flash[:notice] = I18n.t("usuario.create.failure")
    end
    redirect_to usuarios_path
  end

  def edit
    authorize! :update, Usuario
    @user = Usuario.find(params[:id])
  end

  def update
    authorize! :update, Usuario
    @user = Usuario.find(params[:id])
    if @user.update_attributes(params[:usuario])
      flash[:notice] = "Successfully updated Usuario."
      redirect_to usuarios_path
    else
      Rails.logger.info(@user.errors.messages.inspect)
      render :action => 'edit'
    end
  end

  def destroy
    authorize! :destroy, Usuario
    @user = Usuario.find(params[:id])
    if @user.destroy
      flash[:notice] = I18n.t("usuario.delete.sucess")
    end
  end

end
