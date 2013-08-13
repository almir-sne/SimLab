class BancoDeHorasController < ApplicationController
  before_filter :authenticate_usuario!
  def index
    @year =      params[:year].nil?  ? Date.today.year  : params[:year]
    @user =      params[:user].nil?  ? current_user     : Usuario.find(params[:user])
    @month_num = params[:month].nil? ? Date.today.month : params[:month]

    @month = Mes.find_or_initialize_by_ano_and_numero_and_usuario_id @year, @month_num, @user.id
    if @month.horas_contratadas.nil?
      @month.horas_contratadas = @user.horario_mensal
      @month.valor_hora = @user.valor_da_hora
      @month.save
    end

    @dias = @month.dias
    @dias.sort_by! { |d| d.numero  }
    @dia = Dia.new
    @dia.atividades.build
    @projetos = Projeto.all(:order => :nome).collect do |p|
      [p.nome, p.id ]
    end
  end

  def modal
    @year = params[:ano].nil?  ? Date.today.year  : params[:ano]
    @user = params[:user_id].nil?  ? current_user     : Usuario.find(params[:user_id])
    @month = Mes.find(params[:mes])
    if params[:id].nil?
      @dia =  Dia.new
      @dia.atividades.build
    else
      @dia =  Dia.find(params[:id])
    end
    @projetos = Projeto.all(:order => :nome).collect do |p|
      [p.nome, p.id ]
    end
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
    usuario_id = (params[:usuario_id].nil? || params[:usuario_id] == "TODOS") ? Usuario.all.map{|usuario| usuario.id } : params[:usuario_id]
    @ano = params[:ano].nil? ? Date.today.year : params[:ano]
    @mes_numero = params[:mes].nil? ? Date.today.month : params[:mes]
    meses_id = Mes.find_all_by_numero_and_ano(@mes_numero, @ano).map{|month| month.id }
    authorize! :update, :validations
    @atividades =  Atividade.where(:aprovacao => [false, nil], :mes_id => meses_id, :usuario_id => usuario_id).all
    soma =  @atividades.map{|atividade| atividade.duracao}.inject{|sum, x| sum + x}
    @total_horas = soma.nil? ? 0:  (soma/3600).round(2)
    @usuarios = [["TODOS"]] +  Usuario.all(:order => :nome).collect { |p| [p.nome, p.id]  }
    @usuario = params[:usuario_id]
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

end
