class UserController < ApplicationController

  def index
    @users = Usuario.all
    @user = Usuario.new
  end

  def modal
    @user = Usuario.new
  end

end
