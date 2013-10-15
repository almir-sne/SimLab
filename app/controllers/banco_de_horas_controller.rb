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
    if current_user.role == "admin"
      @diasdomes = lista_dias_no_mes(params[:ano].to_i, @month.numero)
    else
      @diasdomes = lista_dias_no_mes_limitado(params[:ano].to_i, @month.numero)
    end
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
 
  def show_mes
    @year = params[:year].nil? ? Date.today.year : params[:year]
    @user = params[:user_id].nil? ? current_user : Usuario.find(params[:user_id])
    query = Mes.find_all_by_ano_and_usuario_id @year, @user.id
    @meses = {}
    @usuarios = Usuario.all(:order => :nome).collect { |p| [p.nome, p.id]  }
    query.map {|e| @meses[e.numero] = e }
  end

  def validar
    authorize! :update, :validations
    #filtrar as atividades
    hoje = Date.today
    meses_id = Mes.find_all_by_numero_and_ano(meses_selecionados(params[:mes_select], hoje), anos_selecionados(params[:ano_select], hoje)).collect{|month|  month.id }
    dias_selecionados  = (params[:dia_select].nil? || params[:dia_select] == "-1") ? (1..31).to_a : params[:dia_select]
    if current_usuario.role == "admin"
      equipe = Usuario.select("nome, id").all(:order => "nome")
      projetos = Projeto.select("nome, id").all(:order => "nome")
      @atividades = seleciona_atividades(usuarios_selecionados(params[:usuario_select]), projetos_selecionados(params[:projeto_select]), aprovacoes_selecionadas(params[:aprovacao_select]), dias_selecionados, meses_id)
    else
      projetos = current_usuario.projetos_coordenados
      equipe = current_usuario.equipe_coordenada_por_projetos(projetos)
      @atividades = monta_atividades(params[:usuario_select], params[:projeto_select], params[:aprovacao_select], meses_id, dias_selecionados)
    end
    #popular os combobox
    soma  = @atividades.collect{|atividade| atividade.duracao}.sum
    @total_horas = soma.nil? ? 0 : (soma/3600).round(2)
    @usuario     = params[:usuario_select].blank? ? params[:usuario_select] = -1 : params[:usuario_select]
    @usuarios    = [["Usuários - Todos", -1]] + equipe.collect { |p| [p.nome, p.id]  }
    @projeto     = params[:projeto_select].blank? ? params[:projeto_select] = -1 : params[:projeto_select]
    @projetos    = [["Projetos - Todos", -1]] + projetos.collect { |p| [p.nome, p.id]  }
    @dia         = params[:dia_select].blank? ? params[:dia_select] = -1 : params[:dia_select]
    @dias        = [["Dias - Todos", -1]] + (1..31).to_a
    @ano         = params[:ano_select].blank? ? params[:ano_select] = hoje.year : params[:ano_select]
    @anos        = [["Anos - Todos", -1]] + (2012..2014).to_a
    @mes         = params[:mes_select].blank? ? params[:mes_select] = hoje.month : params[:mes_select]
    @meses       = [["Meses - Todos", -1]] + (1..12).collect {|mes| [ t("date.month_names")[mes], mes]}
    @aprovacoes  = [["Aprovações - Todas",-1],["Aprovadas",1],["Reprovadas",2],["Não Vistas",3]]
    @aprovacao   = params[:aprovacao_select].blank? ? params[:aprovacao_select] = -1 : params[:aprovacao_select]
  end

  def mandar_validacao
    authorize! :update, :validations
    atividades = params[:atividades].try(:keys)
    atividades ||= []
    for i in atividades
      ativ = params[:atividades][i.to_str]
      Atividade.find(ativ["id"].to_i).update_attributes(
        :aprovacao => ativ["aprovacao"],
        :mensagem => ativ["mensagem"],
        :avaliador_id => current_user.id
      )
    end
    flash[:notice] = I18n.t("banco_de_horas.validation.success")
    redirect_to :back
  end

  def log_de_atividades
    @atividades = Atividade.where(:usuario_id => current_usuario, :aprovacao => [true, false]).
      paginate(:page => params[:page], :per_page => 30).order("updated_at DESC")
  end
end
