class BancoDeHorasController < ApplicationController
  before_filter :authenticate_usuario!
  def index
    @year =      params[:year].nil?  ? Date.today.year  : params[:year]
    @user =      params[:user].nil?  ? current_user     : Usuario.find(params[:user])
    @month_num = params[:month].nil? ? Date.today.month : params[:month]
    @month = Mes.find_or_create_by_ano_and_numero_and_usuario_id @year, @month_num, @user.id
    @diasdomes = lista_dias_no_mes(params[:ano].to_i, @month.numero)
    @dias = @month.dias.order(:numero)
    @ausencias = @month.ausencias.order(:dia)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: {dias: @dias, diames: @diasdomes}}
    end
  end

  def nova_atividade
    @year = params[:ano].nil?  ? Date.today.year  : params[:ano]
    @user = params[:user_id].nil?  ? current_user : Usuario.find(params[:user_id])
    @month = Mes.find(params[:mes])
    @diasdomes = lista_dias_no_mes_limitado(params[:ano].to_i, @month.numero)
    if params[:id].nil?
      @dia =  Dia.new
      @dia.atividades.build
    else
      @dia =  Dia.find(params[:id])
    end
    @projetos = @user.projetos.where("super_projeto_id is not null").order(:nome).collect {|p| [p.nome, p.id ] }
    @projetos_boards = Projeto.all.to_a.each_with_object({}){ |c,h| h[c.id] = c.boards.collect {|c| c.board_id }}.to_json.html_safe
    respond_to do |format|
      format.js
      format.html
    end
  end

  #def show_mes2
    #@year = params[:ano].nil? ? Date.today.year : params[:ano]
    #@user = params[:user_id].nil? ? current_user : Usuario.find(params[:user_id])
    #mes_num = params[:mes].nil? ? Date.today.month : Usuario.find(params[:mes])
    #@mes_model = Mes.find_by_ano_and_usuario_id_and_numero @year, @user.id, mes_num
    #@inicio_do_mes = Date.new(@mes_model.ano, mes_num, 1) 
  #end
  
  def show_mes
    @year = params[:year].nil? ? Date.today.year : params[:year]
    @user = params[:user_id].nil? ? current_user : Usuario.find(params[:user_id])
    query = Mes.find_all_by_ano_and_usuario_id @year, @user.id
    @meses = {}
    @usuarios = Usuario.all(:order => :nome).collect { |p| [p.nome, p.id]  }
    query.map {|e| @meses[e.numero] = e }
  end

  def log_de_atividades
    @atividades = Atividade.where(:usuario_id => current_usuario, :aprovacao => [true, false]).
      paginate(:page => params[:page], :per_page => 30).order("updated_at DESC")
  end
end
