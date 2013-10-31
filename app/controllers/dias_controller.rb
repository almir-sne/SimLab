class DiasController < ApplicationController
  before_filter :authenticate_usuario!

  def new
    @inicio = Date.parse params[:inicio]
    @fim = Date.parse params[:fim]
    @usuario =  Usuario.find_by_id(params[:usuario_id]) || current_user
    @dias_editaveis = (@inicio..@fim).to_a
    if params[:id].nil?
      @dia =  Dia.new
    else
      @dia =  Dia.find(params[:id])
      if @dia.blank?
        @dia =  Dia.new
      end
    end
    @projetos = @usuario.projetos.where("super_projeto_id is not null").order(:nome).collect {|p| [p.nome, p.id ] }
    @projetos_boards = @usuario.boards.pluck(:board_id).uniq.collect {|b| [b,  Board.where(board_id: b).pluck(:projeto_id)]}
    respond_to do |format|
      format.js
      format.html
    end
  end

  def create
    @inicio = Date.parse params[:inicio]
    @fim = Date.parse params[:fim]
    @usuario = Usuario.find_by_id(params[:usuario_id]) || current_user
    
    dia = Dia.find_by_id(params[:dia_id])
    if dia.blank?
      dia = Dia.new
    end
    dia_success = dia.update_attributes(
      :data => Date.parse(params[:dia][:data]),
      :entrada => convert_date(params[:dia], "entrada"),
      :saida => convert_date(params[:dia], "saida"),
      :intervalo => (params[:dia]["intervalo(4i)"].to_f * 3600.0 +  params[:dia]["intervalo(5i)"].to_f * 60.0),
      :usuario_id => @usuario.id
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
          :usuario_id => @usuario.id,
          :aprovacao => nil,
          :data => dia.data,
          :cartao_id => atividade_attr["cartao_id"]
        )
        Atividade.update_on_trello(params[:key], params[:token], atividade_attr["cartao_id"])
      end
    end
    if dia_success and atividades_success
      flash[:notice] = I18n.t("banco_de_horas.create.success")
    else
      flash[:error] = I18n.t("banco_de_horas.create.failure")
    end
    redirect_to dias_path(inicio: @inicio.to_formatted_s, fim: @fim.to_formatted_s, usuario: @usuario.id)
  end

  def destroy
    dia = Dia.find params[:id]
    dia.destroy
    redirect_to :back
  end

  def editar_por_data
    dia = Dia.joins(:mes).where(:numero => params[:dia], :usuario_id => params[:usuario_id], :mes => {:numero => params[:mes], :ano => params[:ano]}).first
    if (!dia.nil?) 
      redirect_to edit_dia_path(dia.id)
    else 
      redirect_to new_dia_path
    end
  end
  
  def index
    @inicio = Date.parse params[:inicio]
    @fim = Date.parse params[:fim]
    @usuario =  Usuario.find_by_id(params[:usuario]) || current_user
    @dias_periodo = dias_no_periodo(@inicio, @fim)
    @dias = Dia.por_periodo(@inicio, @fim, @usuario.id)
    @ausencias = Ausencia.por_periodo(@inicio, @fim, @usuario.id)
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def periodos
    @ano = params[:ano] || Date.today.year
    @usuario = params[:usuario] || current_user
    @usuarios = Usuario.order(:nome)
    @periodos = (1..12).collect{|m| {inicio: Date.new(2013, m, 1), fim: Date.new(2013, m, 1).at_end_of_month}}
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
