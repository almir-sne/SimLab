class DiasController < ApplicationController
  before_filter :authenticate_usuario!

  def new
    @dia = Dia.find_or_initialize_by_data_and_usuario_id(params[:data], params[:usuario_id])
    @usuario = Usuario.find(params[:usuario_id])
    @equipe = @usuario.equipe.collect{|u| [u.nome, u.id]}
    @data = params[:data]
    @projetos = @usuario.meus_projetos
    @projetos_boards = @usuario.boards.pluck(:board_id).uniq.collect {|b| [b,  Board.where(board_id: b).pluck(:projeto_id)]}
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
      :intervalo => (params[:dia]["intervalo(4i)"].to_f * 3600.0 +  params[:dia]["intervalo(5i)"].to_f * 60.0),
    )
    horarios_success = true
    unless params[:dia][:horarios_attributes].nil? 
      params[:dia][:horarios_attributes].each do |lixo, horario_attr|
        horario = Horario.find_by_id horario_attr[:id].to_i
        if horario.blank?
          horario = Horario.new
        end
        if horario_attr["_destroy"] == "1" and !horario.blank?
          horario.destroy()
        else
          horarios_success = horarios_success and horario.update_attributes(
            :entrada => convert_date(params[:dia][:horarios_attributes][lixo], "entrada"),
            :saida => convert_date(params[:dia][:horarios_attributes][lixo], "saida"),
            :dia_id => dia.id
          )
        end
      end
    end
    atividades_success = true
    unless params[:dia][:atividades_attributes].nil? 
      params[:dia][:atividades_attributes].each do |index, atividade_attr|
        atividade = Atividade.find_by_id atividade_attr[:id].to_i
        if atividade.blank?
          atividade = Atividade.new
        end
        if atividade_attr["_destroy"] == "1" and !atividade.blank?
          atividade.destroy()
        else
          atividades_success = atividades_success and atividade.update_attributes(
            :duracao => atividade_attr["horas"].to_i * 60,
            :observacao => atividade_attr["observacao"],
            :projeto_id => atividade_attr["projeto_id"],
            :dia_id => dia.id,
            :usuario_id => dia.usuario.id,
            :aprovacao => nil,
            :trello_id => atividade_attr["trello_id"],
            :data => dia.data
          )
          if atividade_attr["pares_attributes"]
            atividade_attr["pares_attributes"].each do |index, par_attr|
              par = Par.find_by_id par_attr[:id].to_i
              if par.blank?
                par = Par.new
              end
              if par_attr["_destroy"] == "1" and !par.blank?
                par.destroy()
              else
                par.update_attributes(
                  :duracao => par_attr["horas"].to_i * 60,
                  :par_id => par_attr["par_id"].to_i,
                  :atividade_id => atividade.id
                )
              end
            end
          end
        end
        Atividade.update_on_trello(params[:key], params[:token], atividade_attr["trello_id"])
      end
    end
    if dia_success and atividades_success and horarios_success
      flash[:notice] = I18n.t("atividades.create.success")
    else
      flash[:error] = I18n.t("atividades.create.failure")
    end
    periodo = dia.usuario.contrato_atual.periodo_vigente(dia.data)
    redirect_to dias_path(inicio: periodo.first.to_formatted_s, fim: periodo.last.to_formatted_s, usuario: dia.usuario.id)
  end

  def destroy
    dia = Dia.find params[:id]
    dia.destroy
    redirect_to :back
  end

  def editar_por_data
    dia = Dia.find_by_data_and_usuario_id(params[:data], params[:usuario_id])
    if (!dia.nil?) 
      redirect_to edit_dia_path(dia.id)
    else 
      redirect_to new_dia_path
    end
  end
  
  def index
    @today = Date.today
    if params[:data].nil?
      data = @today
    else
      data = Date.parse params[:data]
    end
    if params[:usuario_id].nil?
      @usuario = current_user
    else
      @usuario = Usuario.find(params[:usuario_id])
    end
    if params[:tipo].blank?
      @tipo = 'p'
    else
      @tipo = params[:tipo]
    end
    if params[:inicio].nil? or params[:fim].nil?
      if @tipo == 'p'
        periodo = Usuario.find(@usuario.id).contrato_vigente_em(data).periodo_vigente(data)
        @inicio = periodo.first
        @fim = periodo.last
      elsif @tipo == 'm'
        @inicio = data.beginning_of_month
        @fim = data.end_of_month
      end
    else
      @inicio = Date.parse params[:inicio]
      @fim = Date.parse params[:fim]
    end
    @dias_periodo = dias_no_periodo(@inicio, @fim)
    @dias = Dia.por_periodo(@inicio, @fim, @usuario.id).order(:data).group_by(&:data)
    @ausencias = Ausencia.por_periodo(@inicio, @fim, @usuario.id)
    @equipe = @usuario.equipe
    @projetos = @usuario.meus_projetos
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def periodos
    if params[:usuario_id].nil?
      @usuario = current_user
    else
      @usuario = Usuario.find(params[:usuario_id])
    end
    @ano = params[:ano] || Date.today.year
    @usuarios = Usuario.order(:nome).collect{|u| [u.nome,u.id]}
    @meses = (1..12).collect{|m| {inicio: Date.new(@ano.to_i, m, 1), fim: Date.new(@ano.to_i, m, 1).at_end_of_month}}
    contrato = @usuario.contratos.where('extract(year from inicio) = ? or extract(year from fim) = ?', @ano, @ano).order(:inicio).last
    @periodos = contrato.periodos_por_ano(@ano.to_i)
    @today = Date.today
  end
  
  private

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
