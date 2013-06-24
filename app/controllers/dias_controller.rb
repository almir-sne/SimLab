class DiasController < ApplicationController
  before_filter :authenticate_usuario!

  def edit
    @dia = Dia.find(params[:dia_id])

    respond_to do |format|
      format.html
      format.json {render :json => @atividade}
    end
  end

  def update
    @dia = Dia.find(params[:dia_id])

    respond_to do |format|
      if @dia.update_attributes(params[:dia])
        format.html  { redirect_to action: "index", :dia_id => params[:dia_id], :mes_id=> params[:mes_id], :user_id=> params[:user_id] }#FIXME
      else
        format.html  { redirect_to action: "edit", :dia_id => params[:dia_id], :mes_id=> params[:mes_id], :user_id=> params[:user_id] }
      end
    end
  end

end
