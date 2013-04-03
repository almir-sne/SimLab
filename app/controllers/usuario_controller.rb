class UsuarioController < ApplicationController
  load_and_authorize_resource :class => "Usuario"

  def index
    @users = Usuario.all
    @user ||= Usuario.new
  end

  def new
    @user = Usuario.new
  end

  def create
    @user = Usuario.new(params[:usuario])
    if @user.save
      flash[:notice] = I18n.t("devise.registrations.signed_up_another")
    else
      raise @user.errors.messages.inspect# FIXME
    end
     redirect_to usuario_index_path
  end

  def edit
    @user = Usuario.find(params[:id])
  end

  def update
    @user = Usuario.find(params[:id])
    puts "Passssssssssssssssssssssssssssssssssooouuuuuuuuuuuuuuuuuuuuuuuuu pelo UPDATE"
    if @user.update_attributes(params[:usuario])
      flash[:notice] = "Successfully updated Usuario."
      redirect_to usuario_index_path
    else
      Rails.logger.info(@user.errors.messages.inspect)
      render :action => 'edit'
    end
  end

  def destroy
    @user = Usuario.find(params[:id])
    if @user.destroy
      flash[:notice] = I18n.t("usuario.delete.sucess")
    end
  end

end
