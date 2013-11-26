class DiasController < ApplicationController
  before_filter :authenticate_usuario!

  def new
    @dia = Dia.find_or_initialize_by_data_and_usuario_id(params[:data], params[:usuario_id])
    @usuario = Usuario.find(params[:usuario_id])
    @equipe = @usuario.equipe.collect{|u| [u.nome, u.id]}
    @data = params[:data]
    @projetos = @usuario.projetos.where("super_projeto_id is not null").order(:nome).collect {|p| [p.nome, p.id ] }
    @projetos_boards = @usuario.boards.pluck(:board_id).uniq.collect {|b| [b,  Board.where(board_id: b).pluck(:projeto_id)]}
    respond_to do |format|
      format.js
      format.html
    end
  end
  {"utf8"=>"✓", "authenticity_token"=>"hENwuCB78eaAmmh1JzMIXiaxD0RaVSYhhJeJhpdZ2h4=",
    "data"=>"2013-11-26", "dia_id"=>"2863", "usuario_id"=>"17",
  
    "dia"=>{"entrada(1i)"=>"2013", "entrada(2i)"=>"11", "entrada(3i)"=>"26", "entrada(4i)"=>"02",
      "entrada(5i)"=>"00", "saida(1i)"=>"2013", "saida(2i)"=>"11", "saida(3i)"=>"26", "saida(4i)"=>"02",
      "saida(5i)"=>"00", "intervalo(1i)"=>"2000", "intervalo(2i)"=>"1", "intervalo(3i)"=>"1",
      "intervalo(4i)"=>"00", "intervalo(5i)"=>"00",
      
      "atividades_attributes"=>{"0"=>{"_destroy"=>"false", "projeto_id"=>"12", "horas"=>"120",
          "cartao_id"=>"269",
          "pares_attributes"=>{"1385489291971"=>{"par_id"=>"34", "_destroy"=>"false", "duracao"=>"10"},
            "1385489881783"=>{"par_id"=>"26", "_destroy"=>"false", "duracao"=>"40"}
          }, "observacao"=>"", "id"=>"3821"}}}, "key"=>"98853929c4100832c39e0f3c505d0332", "token"=>"832166084250b32700b75b9a1b4c40dd97d35918b5aa987c8d6cb5b1c77f7953", "commit"=>"Ok", "action"=>"create", "controller"=>"dias"}

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
    params[:dia][:atividades_attributes].each do |index, atividade_attr|
      atividade = Atividade.find_by_id atividade_attr[:id].to_i
      if atividade.blank?
        atividade = Atividade.new
      end
      if atividade_attr["_destroy"] == "1" and !atividade.blank?
        atividade.destroy()
      else
        c = Cartao.find_or_create_by_trello_id(atividade_attr["cartao_id"])
        atividades_success = atividades_success and atividade.update_attributes(
          :duracao => atividade_attr["horas"].to_i * 60,
          :observacao => atividade_attr["observacao"],
          :projeto_id => atividade_attr["projeto_id"],
          :dia_id => dia.id,
          :usuario_id => dia.usuario.id,
          :aprovacao => nil,
          :cartao_id => c.id,
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
      Atividade.update_on_trello(params[:key], params[:token], atividade_attr["cartao_id"])
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
    @ausencias_periodo = Ausencia.joins(:dia).where(dia: {data: (@inicio..@fim).to_a})
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
      0 )
  end
end
