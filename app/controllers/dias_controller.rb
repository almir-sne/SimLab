class DiasController < ApplicationController
  before_action :authenticate_usuario!

  def new
    @usuario = can?(:manage, Dia)? Usuario.find(params[:usuario_id]) : current_user
    @dia = Dia.find_or_create_by_data_and_usuario_id(params[:data], @usuario.id)
    @equipe = @usuario.equipe.collect{|u| [u.nome, u.id]}
    @data = params[:data] || Date.today.to_s
    @projetos = @usuario.meus_projetos
    @projetos_boards = @usuario.boards.pluck(:board_id).uniq.collect {|b| [b,  Board.where(board_id: b).pluck(:projeto_id)]}
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
    atividades_success = true
    registro_success = true
    unless dia_params[:atividades_attributes].nil?
      dia_params[:atividades_attributes].each do |index, atividade_attr|
        atividade = Atividade.find_by_id atividade_attr[:id].to_i
        if atividade.blank?
          atividade = Atividade.new
        end
        if atividade_attr["_destroy"] == "1" and !atividade.blank?
          atividade.destroy()
        else
          atividade.attributes = {
            :duracao => atividade_attr["horas"].to_i * 60,
            :observacao => atividade_attr["observacao"],
            :projeto_id => atividade_attr["projeto_id"],
            :dia_id => dia.id,
            :usuario_id => dia.usuario.id,
            :aprovacao => nil,
            :trello_id => atividade_attr["trello_id"],
            :data => dia.data
          }
          reg = Registro.new :autor_id => current_user.id
          reg.transforma_hash_em_modificacao atividade.changes
          atividades_success = atividades_success and atividade.save
          reg.atividade_id = atividade.id
          unless reg.modificacao.blank?
            registro_success = registro_success and reg.save
          end
          if(!(atividade_attr[:mensagem].blank?) && !(atividade_attr[:mensagem][:conteudo].blank?))
            Mensagem.create(atividade_attr[:mensagem])
          end
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
      end
    end
    unless params[:cartao].nil?
      params[:cartao].each do |filho_id, parametros|
        filho = Cartao.find_or_create_by_trello_id(filho_id)
        if parametros["tags"]
          tags_do_cartao = filho.tags
          tags_form = parametros["tags"].split(",").collect{|n| n.strip}
          tags_banco = tags_do_cartao.collect{|t| t.nome}
          tags_a_adicionar = tags_form - tags_banco
          tags_a_remover = tags_banco - tags_form
          tags_a_adicionar.each do |tag_nome|
            if !tag_nome.blank?
              tag = Tag.find_by_nome tag_nome
              if tag.blank?
                tag = Tag.new(nome: tag_nome)
                tag.save
              end
              if !tags_do_cartao.include?(tag)
                tags_do_cartao << tag
              end
            end
          end
          tags_a_remover.each do |tag_nome|
            tag = Tag.find_by_nome tag_nome
            if !tag.blank?
              tags_do_cartao.delete(tag);
            end
          end
        end     
        pai = Cartao.find_or_create_by_trello_id(parametros["cartao_pai"])
        filho.pai = pai
        filho.save
        Cartao.update_on_trello(params[:key], params[:token], filho.trello_id, tags_do_cartao.collect{|t| t.nome})
      end
    end
    if dia_success and atividades_success and horarios_success and registro_success
      flash[:notice] = I18n.t("atividades.create.success")
    else
      flash[:error] = I18n.t("atividades.create.failure")
    end
    redirect_to dias_path(data: dia.data, usuario: dia.usuario.id)
  end

  def atualizar_tags_cartoes
    if (!params[:key].blank? and !params[:token].blank?)
      Cartao.all.each do |c|
        my_card_master_id = c.trello_id
        data = Cartao.get_trello_data(params[:key], params[:token], my_card_master_id)
        unless (data == :error)

          tags_list = extract_tags(data["name"])

          tags_string = ""
          tags_list.each do |t|
            tags_string += t.to_s + ", "
          end

          tags_do_cartao = c.tags
          tags_form = tags_string.split(",").collect{|n| n.strip}
          tags_banco = tags_do_cartao.collect{|t| t.nome}
          tags_a_adicionar = tags_form - tags_banco
          tags_a_remover = tags_banco - tags_form
          tags_a_adicionar.each do |tag_nome|
            if !tag_nome.blank?
              tag = Tag.find_by_nome tag_nome
              if tag.blank?
                tag = Tag.new(nome: tag_nome)
                tag.save
              end
              if !tags_do_cartao.include?(tag)
                tags_do_cartao << tag
              end
            end
          end
          tags_a_remover.each do |tag_nome|
            tag = Tag.find_by_nome tag_nome
            if !tag.blank?
              tags_do_cartao.delete(tag);
            end
          end

          if (tags_do_cartao.blank?)
            puts "Cartão sem Tags"
          else
            puts tags_do_cartao.collect{|t| t.nome}.to_s
          end
        end
      end
    end
    redirect_to :back
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
    @today   = Date.today
    data     = params[:data].nil? ? @today : Date.parse(params[:data])
    @usuario = (params[:usuario_id].nil? || cannot?(:manage, Dia)) ? current_user : Usuario.find(params[:usuario_id])
    @tipo    = params[:tipo].blank? ? 'p' : params[:tipo]
    if params[:inicio].nil? or params[:fim].nil?
      if @tipo == 'p'
        periodo = Usuario.find(@usuario.id).contrato_vigente_em(data).periodo_vigente(data)
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
  
  

  def cartao_pai
    cartao = Cartao.find_or_create_by_trello_id(params[:cartao_id])
    unless cartao.pai.blank?
      render json: cartao.pai.trello_id.to_json
    else
      render json: "".to_json
    end
  end

  private

  def dia_params
    params.require(:dia).permit(:data, :usuario_id, :cartao,
      atividades_attributes:[:id, :projeto_id, :horas, :trello_id, :observacao, :_destroy,
          pares_attributes: [:id, :par_id, :_destroy, :horas]],
      horarios_attributes: [:id, :entrada, :saida, :_destroy])
  end

  def cartao_tags
    cartao = Cartao.find_by_trello_id(params[:cartao_id])
    unless cartao.blank?
      tags = ""
      cartao.tags.each do |t|
        tags += t.nome + ", "
      end
      render json: tags.to_json
    else
      render json: "".to_json
    end
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
