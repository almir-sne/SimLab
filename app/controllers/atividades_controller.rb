class AtividadesController < ApplicationController
  before_filter :authenticate_usuario!

  def index
    @dia_id = params[:dia_id]
    @mes_id = params[:mes_id]
    @user_id = params[:user_id]
    
    @atividades = Atividade.find_all_by_dia_id_and_user_id(@dia_id, current_usuario)
    @atividades.sort! {|a| a.dia.numero}
  end  
  
  def edit
    @dia_id = params[:dia_id]
    @mes_id = params[:mes_id]
    @user_id = params[:user_id]
    
    @atividade = Atividade.find(params[:id])
    
    respond_to do |format|
      format.html 
      format.json {render :json => @atividade}
    end
    
  end
  def new
    @dia_id = params[:dia_id]
    @mes_id = params[:mes_id]
    @user_id = params[:user_id]
    
    @atividade = Atividade.new 
    respond_to do |format|
      format.html 
      format.json {render :json => @atividade}
    end
  end
  
  def destroy
    atividade = Atividade.find(params[:id])
    atividade.destroy()
    redirect_to :back
  end
  
  def create
    atividade_attr = params[:atividade]
    @atividade = Atividade.new(
      :horas => (atividade_attr["horas(4i)"].to_f * 3600) +  (atividade_attr["horas(5i)"].to_f * 60),
      :observacao => atividade_attr["observacao"],
      :projeto_id => atividade_attr["projeto_id"],
      :aprovacao => nil,
      :dia_id => params[:dia_id],
      :mes_id => params[:mes_id],
      :user_id => params[:user_id]
    )     
    
    respond_to do |format|
      if @atividade.save
        format.html  { redirect_to action: "index", :dia_id => params[:dia_id], :mes_id=> params[:mes_id], :user_id=> params[:user_id] }
      else
        format.html  { redirect_to action: "new", :dia_id => params[:dia_id], :mes_id=> params[:mes_id], :user_id=> params[:user_id] }
      end
    end
    
  end
  def update
    atividade_attr = params[:atividade]
    @atividade = Atividade.find(params[:id])
    respond_to do |format|
      if @atividade.update_attributes(
          :horas => (atividade_attr["horas(4i)"].to_f * 3600) +  (atividade_attr["horas(5i)"].to_f * 60),
          :observacao => atividade_attr["observacao"],
          :projeto_id => atividade_attr["projeto_id"],
          :aprovacao => nil,
          :dia_id => params[:dia_id],
          :mes_id => params[:mes_id],
          :user_id => params[:user_id]
        )
        format.html  { redirect_to action: "index", :dia_id => params[:dia_id], :mes_id=> params[:mes_id], :user_id=> params[:user_id] }
      else
        format.html  { redirect_to action: "edit", :dia_id => params[:dia_id], :mes_id=> params[:mes_id], :user_id=> params[:user_id] }
      end
    end    
  end
end
