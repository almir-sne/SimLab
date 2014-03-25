class DiasController < ApplicationController
  include ApplicationHelper
  before_action :authenticate_usuario!

  def new
    @usuario = can?(:manage, Dia)? Usuario.find(params[:usuario_id]) : current_user
    @data = Date.parse(params[:data]) || Date.today.to_s
    @dia = Dia.find_or_create_by_data_and_usuario_id(@data, @usuario.id)
    @equipe = @usuario.equipe.collect{|u| [u.nome, u.id]}
    
    @projetos = @usuario.meus_projetos_array
    @boards = @usuario.boards.pluck(:board_id).uniq
    @reunioes = Reuniao.joins(:participantes).where(participantes: {usuario_id: @usuario.id},
      inicio: @data.at_beginning_of_day..@data.at_end_of_day)
    respond_to do |format|
      format.js
      format.html
    end
  end

  def update
    if params[:dia_id].blank? 
      @dia = Dia.new(data: Date.parse(params[:data]), usuario_id: params[:usuario_id])
    else
      @dia = Dia.find(params[:dia_id])
    end
    dia_success = @dia.update_attributes(
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
            :entrada => convert_date(@dia.data, dia_params[:horarios_attributes][lixo][:entrada]),
            :saida => convert_date(@dia.data, dia_params[:horarios_attributes][lixo][:saida]),
            :dia_id => @dia.id
          )
        end
      end
    end
    respond_to do |format|
      if dia_success and horarios_success
        format.js
      end
    end
  end

  def destroy
    dia = Dia.find params[:id]
    dia.destroy
    redirect_to :back
  end

  def index
    @usuario = (params[:usuario_id].nil? || cannot?(:manage, Dia)) ? current_user : Usuario.find(params[:usuario_id])
    @tipo = params[:tipo] || 'm'
    if params[:inicio]
      @inicio = Date.parse params[:inicio]
      @fim = Date.parse params[:fim] if params[:fim]
    else
      @inicio = Date.today.at_beginning_of_month
      @fim = Date.today.at_end_of_month
    end
    case params[:toggle]
    when 's'
      @tipo = 's'
      @fim = @inicio.at_end_of_week(:sunday)
      @inicio = @inicio.at_beginning_of_week(:sunday)
    when 'p'
      @tipo = 'p'
      periodo = @usuario.contrato_vigente_em(@inicio).periodo_vigente(@inicio)
      @fim = periodo.last
      @inicio = periodo.first
    when 'm'
      @tipo = 'm'
      @fim = @inicio.at_end_of_month
      @inicio = @inicio.at_beginning_of_month
    end
    case params[:commit]
    when 'previous_mes'
      @tipo = 'm'
      @fim = @inicio.last_month.at_end_of_month
      @inicio = @inicio.last_month.at_beginning_of_month
    when 'next_mes'
      @tipo = 'm'
      @fim = @inicio.next_month.at_end_of_month
      @inicio = @inicio.next_month.at_beginning_of_month
    when 'previous_ano'
      @tipo = 'm'
      @fim = @inicio.last_year.at_end_of_month
      @inicio = @inicio.last_year.at_beginning_of_month
    when 'next_ano'
      @tipo = 'm'
      @fim = @inicio.next_year.at_end_of_month
      @inicio = @inicio.next_year.at_beginning_of_month
    when 'next_semana'
      @tipo = 's'
      @fim = @inicio.next_week(:sunday).at_end_of_week(:sunday)
      @inicio = @inicio.next_week(:sunday).at_beginning_of_week(:sunday)
    when 'previous_semana'
      @tipo = 's'
      @fim = @inicio.last_week(:sunday).at_end_of_week(:sunday)
      @inicio = @inicio.last_week(:sunday).at_beginning_of_week(:sunday)
    when 'next_periodo'
      @tipo = 'p'
      @inicio = @inicio.next_month
      periodo = @usuario.contrato_vigente_em(@inicio).periodo_vigente(@inicio)
      @fim = periodo.last
      @inicio = periodo.first
    when 'previous_periodo'
      @tipo = 'p'
      @inicio = @inicio.last_month
      periodo = @usuario.contrato_vigente_em(@inicio).periodo_vigente(@inicio)
      @fim = periodo.last
      @inicio = periodo.first
    end
    if can? :manage, :usuario
      @usuarios = Usuario.por_status
    end
    @projetos          = @usuario.meus_projetos_array
    @dias_periodo      = dias_no_periodo(@inicio, @fim)
    @dias              = Dia.includes(:ausencias).includes(:atividades).por_periodo(@inicio, @fim, @usuario.id).order(:data).group_by(&:data)
    @ausencias         = Ausencia.por_periodo(@inicio, @fim, @usuario.id)
    @hash_resumo       = monta_resumo_dia(@inicio, @fim, @usuario)
    @reunioes          = Reuniao.joins(:participantes).where(participantes: {usuario_id: @usuario.id},
      inicio: @inicio..@fim).group_by{|r| r.inicio.to_date}
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def periodos
    @today = Date.today
    @usuario = (params[:usuario_id].nil? || cannot?(:manage, Dia)) ? current_user : Usuario.find(params[:usuario_id])
    @ano = (params[:ano] || Date.today.year).to_i
    @tipo = params[:toggle] || params[:tipo] || 'm'
    case params[:commit]
    when 'previous_ano'
      @ano = @ano - 1
    when 'next_ano'
      @ano = @ano + 1
    end
    if @tipo == 'm'
      @intervalo = (1..12).collect{|m| {inicio: Date.new(@ano.to_i, m, 1), fim: Date.new(@ano.to_i, m, 1).at_end_of_month}}
    elsif @tipo == 's'
      data_inicial = (@today - 1.month).sunday
      contrato = @usuario.contratos.where('extract(year from inicio) <= ? or extract(year from fim) >= ?', @ano, @ano).order(:inicio).last
      @intervalo = Array.new
      fim_do_ano = @today.at_end_of_year
      fim_do_contrato = contrato.fim
      while data_inicial < fim_do_ano and data_inicial < fim_do_contrato do
        @intervalo << {inicio: data_inicial.beginning_of_week(:sunday), fim: data_inicial.end_of_week(:sunday)}
        data_inicial = data_inicial + 1.week
      end
    elsif @tipo == 'p'
      contrato = @usuario.contratos.where('extract(year from inicio) <= ? and extract(year from fim) >= ?', @ano, @ano).order(:inicio).last
      if contrato.blank?
        @intervalo = @usuario.contrato_atual.periodos_por_ano
        flash.now[:notice] = I18n.t("dias.periodos.inexistente")
      else
        if params[:inicio].blank? and params[:fim].blank?
          @intervalo = contrato.periodos_por_ano(@ano.to_i)
        else
          @intervalo = contrato.periodos_entre_datas(params[:inicio].to_date,params[:fim].to_date)
        end
      end
    end
    if can? :manage, :usuario
      @usuarios = Usuario.por_status
    end
    @projetos = @usuario.meus_projetos_array
  end

  private

  def dia_params
    params.require(:dia).permit(:data, :usuario_id, :cartao,
      atividades_attributes: [:id, :projeto_id, :horas, :trello_id, :observacao, :_destroy,
        pares_attributes: [:id, :par_id, :_destroy, :horas],
        mensagem: [:conteudo, :atividade_id, :autor_id]
      ],
      horarios_attributes: [:id, :entrada, :saida, :_destroy])
  end
  
  def convert_date(data, hora_string)
    horario = hora_string.split(':')
    hora_date = DateTime.new(data.year, data.month, data.day, horario[0].to_i, horario[1].to_i)
    return hora_date
  end  
  
  def monta_resumo_dia(inicio, fim, usuario)
    dias = Dia.where(data: inicio..fim, usuario_id: usuario)
    hash = Hash.new
    dias.each do |dia_selecionado| 
      horas = dia_selecionado.horas_atividades_todas
      entrada = dia_selecionado.entrada_formatada.to_s
      if (entrada == "")
        entrada = "Não Informada"
      end
      saida = dia_selecionado.saida_formatada.to_s
      if (saida == "")
        saida = "Não Informada"
      end
      intervalo = dia_selecionado.intervalo
      if intervalo > 0
        intervalo = int_to_horas intervalo
      else
        intervalo = "Não Informado"
      end
      resumo = "Resumo do Dia<br/>"
      resumo += "Horas Trabalhadas: #{horas} <br/>"
      resumo += "Entrada: #{entrada} <br/>"
      resumo += "Saída: #{saida} <br/>"
      resumo += "Intervalo: #{intervalo} <br/>"
      hash[dia_selecionado.data] = resumo
    end
    return hash;
  end
  
end
