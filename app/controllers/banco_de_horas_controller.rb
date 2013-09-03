class BancoDeHorasController < ApplicationController
  before_filter :authenticate_usuario!
  def index
    @year =      params[:year].nil?  ? Date.today.year  : params[:year]
    @user =      params[:user].nil?  ? current_user     : Usuario.find(params[:user])
    @month_num = params[:month].nil? ? Date.today.month : params[:month]
    @month = Mes.find_or_initialize_by_ano_and_numero_and_usuario_id @year, @month_num, @user.id
    if @month.horas_contratadas.nil?
      @month.horas_contratadas = @user.horario_data Date.new(@month.ano, @month.numero, 1)
      @month.save
    end
    @diasdomes = lista_dias_no_mes(params[:ano].to_i, @month.numero)
    @dias = @month.dias
    @dias.sort_by! { |d| d.numero  }
  end

  def modal
    @year = params[:ano].nil?  ? Date.today.year  : params[:ano]
    @user = params[:user_id].nil?  ? current_user     : Usuario.find(params[:user_id])
    @month = Mes.find(params[:mes])
    @diasdomes = lista_dias_no_mes(params[:ano].to_i, @month.numero)
    if params[:id].nil?
      @dia =  Dia.new
      @dia.atividades.build
    else
      @dia =  Dia.find(params[:id])
    end
    @projetos = Projeto.all(:order => :nome).collect {|p| [p.nome, p.id ] }
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
    @ano         = params[:ano].nil? ? Date.today.year  : params[:ano]
    @mes_numero  = params[:mes].nil? ? Date.today.month : params[:mes]
    dia_numero      = (params[:dia].nil? || params[:dia] == "-1") ? (1..31).to_a : params[:dia]
    meses_id     = Mes.find_all_by_numero_and_ano(@mes_numero, @ano).collect{|month| month.id }
    if current_usuario.role == "admin"   
      equipe = Usuario.all(:order => "nome")
      projetos = Projeto.all(:order => "nome")
    else
      projetos = current_usuario.projetos_coordenados
      equipe = current_usuario.equipe(projetos)
    end
    if params[:usuario_id].nil? || params[:usuario_id] == "-1"     
      usuarios_selected = Usuario.select(:id)
    else
      usuarios_selected = Usuario.where(:id => params[:usuario_id].to_i)
    end
    if params[:projeto_id].nil? || params[:projeto_id] == "-1"
      projetos_selected = Projeto.select(:id)
    else
      projetos_selected = Projeto.where(:id => params[:projeto_id].to_i)
    end
    @atividades = Atividade.joins(:dia).where(
      :aprovacao => [false, nil],
      :mes_id => meses_id,
      :usuario_id => usuarios_selected,
      :projeto_id => projetos_selected,
      dia: {numero: dia_numero}
    )
    soma         =  @atividades.collect{|atividade| atividade.duracao}.sum
    @total_horas = soma.nil? ? 0 : (soma/3600).round(2)
    @usuario     = params[:usuario_id].blank? ? params[:usuario_id] = -1 : params[:usuario_id]
    @usuarios    = [["Usuários - Todos", -1]] + equipe.collect { |p| [p.nome, p.id]  }
    @projeto     = params[:projeto_id].blank? ? params[:projeto_id] = -1 : params[:projeto_id]
    @projetos    = [["Projetos - Todos", -1]] + projetos.collect { |p| [p.nome, p.id]  }
    @dia         = params[:dia].blank? ? params[:dia] = -1 : params[:dia]
    @dias        = [["Dias - Todos", -1]] + (1..31).to_a
    @anos        = [["Anos - Todos", -1]] + (2012..2014).to_a
    @meses       = [["Meses - Todos", -1]] + (1..12).collect {|mes| [ t("date.month_names")[mes], mes]} 
  end

  def mandar_validacao
    authorize! :update, :validations
    atividades = params[:atividades].try(:keys)
    atividades ||= []
    for i in atividades
      ativ = params[:atividades][i.to_str]
      if ativ["reprovacao"]
        veredito = false
      elsif ativ["aprovacao"]
        veredito = true
      else
        veredito = nil
      end
      Atividade.find(ativ["id"].to_i).update_attributes(
        :aprovacao => veredito,
        :mensagem => ativ["mensagem"],
        :avaliador_id => current_user.id
      )
    end
    flash[:notice] = I18n.t("banco_de_horas.validation.sucess")
    redirect_to :back
  end
  
  private
  def lista_dias_no_mes(ano, mes)
    data_final = Date.new(ano, mes, 5).at_end_of_month.day
    (1..data_final).to_a
  end

end
