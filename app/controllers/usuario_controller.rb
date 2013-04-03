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
      flash[:notice] = "Successfully! created Usuario."
    else
      raise "error"
    end
     redirect_to usuario_index_path
  end

  def edit
    @user = Usuario.find(params[:id])
  end

  def update
    @user = Usuario.find(params[:id])
    params[:usuario].delete(:password) if params[:usuario][:password].blank?
    params[:usuario].delete(:password_confirmation) if params[:usuario][:password].blank? and params[:usuario][:password_confirmation].blank?
    if @user.update_attributes(params[:usuario])
      flash[:notice] = "Successfully updated Usuario."
      redirect_to root_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user = Usuario.find(params[:id])
    if @user.destroy
      flash[:notice] = "Successfully deleted Usuario."
    end
  end

end
