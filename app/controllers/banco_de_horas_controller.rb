class BancoDeHorasController < ApplicationController
  before_filter :authenticate_usuario!
  def index
    @year =      params[:year].nil?  ? Date.today.year  : params[:year]
    @user =      params[:user].nil?  ? current_user     : Usuario.find(params[:user])
    @month_num = params[:month].nil? ? Date.today.month : params[:month]
    @month = Mes.find_or_create_by_ano_and_numero_and_usuario_id @year, @month_num, @user.id
    @diasdomes = lista_dias_no_mes(params[:ano].to_i, @month.numero)
    @dias = @month.dias
    @dias.sort_by! { |d| d.numero  }
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: {dias: @dias,  diames: @diasdomes}}
    end
  end

  def modal
    @year = params[:ano].nil?  ? Date.today.year  : params[:ano]
    @user = params[:user_id].nil?  ? current_user : Usuario.find(params[:user_id])
    @month = Mes.find(params[:mes])
    @diasdomes = lista_dias_no_mes(params[:ano].to_i, @month.numero)
    if params[:id].nil?
      @dia =  Dia.new
      @dia.atividades.build
    else
      @dia =  Dia.find(params[:id])
    end
    @projetos = @user.projetos(:order => :nome).collect {|p| [p.nome, p.id ] }
    @projetos_boards = Projeto.all.to_a.each_with_object({}){ |c,h| h[c.id] = c.boards.collect {|c| c.board_id }}.to_json.html_safe
    respond_to do |format|
      format.html
      format.js
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
    meses_id = Mes.find_all_by_numero_and_ano(meses_selecionados(params[:mes], hoje), anos_selecionados(params[:ano], hoje)).collect{|month| month.id }
    dias_selecionados  = (params[:dia].nil? || params[:dia] == "-1") ? (1..31).to_a : params[:dia]
    @atividades = Atividade.joins(:dia).where(
      :aprovacao => [false, nil],
      :mes_id => meses_id,
      :usuario_id => usuarios_selecionados(params[:usuario_id]),
      :projeto_id => projetos_selecionados(params[:projeto_id]),
      dia: {numero: dias_selecionados}
    )
    #popular os combobox
    if current_usuario.role == "admin"
      equipe = Usuario.all(:order => "nome")
      projetos = Projeto.all(:order => "nome")
    else
      projetos = current_usuario.projetos_coordenados
      equipe = current_usuario.equipe(projetos)
    end
    soma         =  @atividades.collect{|atividade| atividade.duracao}.sum
    @total_horas = soma.nil? ? 0 : (soma/3600).round(2)
    @usuario     = params[:usuario_id].blank? ? params[:usuario_id] = -1 : params[:usuario_id]
    @usuarios    = [["Usuários - Todos", -1]] + equipe.collect { |p| [p.nome, p.id]  }
    @projeto     = params[:projeto_id].blank? ? params[:projeto_id] = -1 : params[:projeto_id]
    @projetos    = [["Projetos - Todos", -1]] + projetos.collect { |p| [p.nome, p.id]  }
    @dia         = params[:dia].blank? ? params[:dia] = -1 : params[:dia]
    @dias        = [["Dias - Todos", -1]] + (1..31).to_a
    @ano         = params[:ano].blank? ? params[:ano] = hoje.year : params[:ano]
    @anos        = [["Anos - Todos", -1]] + (2012..2014).to_a
    @mes         = params[:mes].blank? ? params[:mes] = hoje.month : params[:mes]
    @meses       = [["Meses - Todos", -1]] + (1..12).collect {|mes| [ t("date.month_names")[mes], mes]}
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
    flash[:notice] = I18n.t("banco_de_horas.validation.sucess")
    redirect_to :back
  end

  def log_de_atividades
    @atividades = Atividade.where(:usuario_id => current_usuario, :aprovacao => [true, false]).
      paginate(:page => params[:page], :per_page => 30).order("updated_at DESC")
  end
  
  def ausencia
    @user = params[:user_id].nil?  ? current_user : Usuario.find(params[:user_id])
    @month = Mes.find(params[:mes])
    @diasdomes = lista_dias_no_mes(@month.ano, @month.numero)
    @ausencia = Ausencia.new
    
    respond_to do |format|
      format.html
      format.js
    end
  end

  private
  def lista_dias_no_mes(ano, mes)
    data_final = Date.new(ano, mes, 5).at_end_of_month.day
    (1..data_final).to_a
  end

  def anos_selecionados(param_anos, hoje)
    if param_anos.nil?
      hoje.year
    elsif param_anos == "-1"
      [2012,2013,2014]
    else
      param_anos
    end
  end

  def meses_selecionados(param_meses, hoje)
    if param_meses.nil?
      return hoje.month
    elsif param_meses == "-1"
      (1..12).to_a
    else
      param_meses
    end
  end

  def usuarios_selecionados(param_usuarios)
    if param_usuarios.nil? || param_usuarios == "-1"
      Usuario.select(:id)
    else
      Usuario.where(:id => param_usuarios.to_i)
    end
  end

  def projetos_selecionados(param_projetos)
    if param_projetos.nil? || param_projetos == "-1"
      Projeto.select(:id)
    else
      Projeto.where(:id => param_projetos .to_i)
    end
  end
end
