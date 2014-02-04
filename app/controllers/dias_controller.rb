class DiasController < ApplicationController
  before_action :authenticate_usuario!

  def new
    @usuario = can?(:manage, Dia)? Usuario.find(params[:usuario_id]) : current_user
    @dia = Dia.find_or_create_by_data_and_usuario_id(params[:data], @usuario.id)
    @equipe = @usuario.equipe.collect{|u| [u.nome, u.id]}
    @data = params[:data] || Date.today.to_s
    @projetos = @usuario.meus_projetos
    @boards = @usuario.boards.pluck(:board_id).uniq
    Atividade.where(:dia_id => @dia.id).all.each{ |ati| ati.mensagens.where{autor_id != ati.usuario_id}.update_all :visto => true}
    respond_to do |format|
      format.js
      format.html
    end
  end

  def create
    if params[:dia_id].blank?
      dia = Dia.new(data: Date.parse(params[:data]), usuario_id: params[:usuario_id])
    else
      dia = Dia.find(params[:dia_id])
    end
    dia_success = dia.update_attributes(
      :intervalo => (dia_params["intervalo(4i)"].to_f * 3600.0 +  dia_params["intervalo(5i)"].to_f * 60.0),
    )
    horarios_success = true
    unless dia_params[:horarios_attributes].nil?
      dia_params[:horarios_attributes].each do |lixo, horario_attr|
        horario = Horario.find_by_id horario_attr[:id].to_i
        if horario.blank?
          horario = Horario.new
        end
        if horario_attr["_destroy"] == "1" and !horario.blank?
          horario.destroy()
        else
          horarios_success = horarios_success and horario.update_attributes(
            :entrada => convert_date(dia_params[:horarios_attributes][lixo], "entrada"),
            :saida => convert_date(dia_params[:horarios_attributes][lixo], "saida"),
            :dia_id => dia.id
          )
        end
      end
    end
    if dia_success
      flash[:notice] = I18n.t("atividades.create.success")
    else
      flash[:error] = I18n.t("atividades.create.failure")
    end
    redirect_to dias_path(data: dia.data, usuario: dia.usuario.id)
  end

  def destroy
    dia = Dia.find params[:id]
    dia.destroy
    redirect_to :back
  end

  def index
    @today   = Date.today
    data     = params[:data].nil? ? @today : Date.parse(params[:data])
    @usuario = (params[:usuario_id].nil? || cannot?(:manage, Dia)) ? current_user : Usuario.find(params[:usuario_id])
    @tipo    = params[:tipo].blank? ? 'm' : params[:tipo]
    if @usuario.contratos.count == 0
      @tipo = 'm'
    elsif params[:tipo].blank?
      @tipo = 'p'
    else
      @tipo = params[:tipo]
    end
    if params[:inicio].nil? or params[:fim].nil?
      if @tipo == 'p'
        periodo = @usuario.contrato_vigente_em(data).periodo_vigente(data)
        @inicio = periodo.first
        @fim = periodo.last
      elsif @tipo == 'm'
        @inicio = data.beginning_of_month
        @fim = data.end_of_month
      elsif @tipo == 's'
        @inicio = data.beginning_of_week(:sunday)
        @fim = data.end_of_week(:sunday)
      end
    else
      @inicio = Date.parse params[:inicio]
      @fim = Date.parse params[:fim]
    end
    if can? :manage, :usuario
      @usuarios = Usuario.order(:nome).collect{|u| [u.nome,u.id]}
    end
    @projetos          = @usuario.meus_projetos
    @dias_periodo      = dias_no_periodo(@inicio, @fim)
    @dias              = Dia.por_periodo(@inicio, @fim, @usuario.id).order(:data).group_by(&:data)
    @ausencias         = Ausencia.por_periodo(@inicio, @fim, @usuario.id)
    @equipe            = @usuario.equipe
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def periodos
    @today = Date.today
    if params[:usuario_id].nil?
      @usuario = current_user
    else
      @usuario = Usuario.find(params[:usuario_id])
    end
    @tipo = params[:tipo] || 'p'
    if (params[:date])
      date_year = params[:data].to_date.year
    end
    @ano = date_year || params[:ano] || Date.today.year
    if @tipo == 'm'
      @intervalo = (1..12).collect{|m| {inicio: Date.new(@ano.to_i, m, 1), fim: Date.new(@ano.to_i, m, 1).at_end_of_month}}
    elsif @tipo == 's'
      data_inicial = (@today - 1.month).sunday
      contrato = @usuario.contratos.where('extract(year from inicio) <= ? or extract(year from fim) >= ?', @ano, @ano).order(:inicio).last
      @intervalo = Array.new
      fim = @today + 2.week
      while data_inicial < fim do
        @intervalo << {inicio: data_inicial.beginning_of_week(:sunday), fim: data_inicial.end_of_week(:sunday)}
        data_inicial = data_inicial + 1.week
      end
    elsif @tipo == 'p'
      contrato = @usuario.contratos.where('extract(year from inicio) <= ? and extract(year from fim) >= ?', @ano, @ano).order(:inicio).last
      if (!contrato.blank?)
        if params[:inicio].blank? and params[:fim].blank?
          @intervalo = contrato.periodos_por_ano(@ano.to_i)
        else
          @intervalo = contrato.periodos_entre_datas(params[:inicio].to_date,params[:fim].to_date)
        end
      else
        @intervalo = nil
      end
    end
    #if can? :manage, :usuario
    #@usuarios = Usuario.order(:nome).collect{|u| [u.nome,u.id]}
    #end
    @usuarios = Usuario.order(:nome).collect{|u| [u.nome,u.id]}
    @projetos          = @usuario.meus_projetos
  end

  private

  def dia_params
    params.require(:dia).permit(:data, :usuario_id, :cartao,
      atividades_attributes:[:id, :projeto_id, :horas, :trello_id, :observacao, :_destroy,
        pares_attributes: [:id, :par_id, :_destroy, :horas]],
      horarios_attributes: [:id, :entrada, :saida, :_destroy])
  end

  def convert_date(hash, date_symbol_or_string)
    attribute = date_symbol_or_string.to_s
    return DateTime.new(
      hash[attribute + '(1i)'].to_i,
      hash[attribute + '(2i)'].to_i,
      hash[attribute + '(3i)'].to_i,
      hash[attribute + '(4i)'].to_i,
      hash[attribute + '(5i)'].to_i,
      0)
  end
end
