class DiasController < ApplicationController
  before_filter :authenticate_usuario!

  def new
    @dia = Dia.find_or_initialize_by_data_and_usuario_id(params[:data], params[:usuario_id])
    @usuario = Usuario.find(params[:usuario_id])
    @data = params[:data]
    @projetos = @usuario.projetos.where("super_projeto_id is not null").order(:nome).collect {|p| [p.nome, p.id ] }
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
      :entrada => convert_date(params[:dia], "entrada"),
      :saida => convert_date(params[:dia], "saida"),
      :intervalo => (params[:dia]["intervalo(4i)"].to_f * 3600.0 +  params[:dia]["intervalo(5i)"].to_f * 60.0),
    )
    atividades_success = true
    params[:dia][:atividades_attributes].each do |lixo, atividade_attr|
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
          :cartao_id => atividade_attr["cartao_id"],
          :data => dia.data
        )
        Atividade.update_on_trello(params[:key], params[:token], atividade_attr["cartao_id"])
      end
    end
    if dia_success and atividades_success
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
    if params[:usuario_id].nil?
      @usuario = current_user
    else
      @usuario = Usuario.find(params[:usuario_id])
    end
    @inicio = Date.parse params[:inicio]
    @fim = Date.parse params[:fim]
    @dias_periodo = dias_no_periodo(@inicio, @fim)
    @dias = Dia.por_periodo(@inicio, @fim, @usuario.id).order(:data)
    @ausencias = Ausencia.por_periodo(@inicio, @fim, @usuario.id)
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
      0 )
  end
end
