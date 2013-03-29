class UserController < ApplicationController

  def index
    @users = Usuario.all
  end
end
