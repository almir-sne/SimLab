require 'holidays'
require 'holidays/br'
module DiasHelper
  def tem_reprovacao?(inicio, fim, usuario_id)
    !Atividade.where(aprovacao: false, data: inicio..fim, usuario_id: usuario_id).blank?
  end
  
  def periodo_link(inicio, fim, usuario_id)
    "#{inicio.strftime("%d/%m")} - #{fim.strftime("%d/%m")}  <br/> <br/>" +
      "<b> #{horas_trabalhadas_aprovadas(inicio, fim, usuario_id)} / #{horas_contratadas(inicio, usuario_id)} </b>"
  end
  
  #supondo que isso só seja chamado para o periodo atual
  def dias_uteis_restantes(fim, usuario_id)
    calcula_dias_uteis_restantes(fim, usuario_id).to_s
  end

  #horas trabalhadas num dado período
  def horas_trabalhadas(inicio, fim, usuario_id)
    string_hora(calcula_minutos_trabalhados(false, inicio, fim, usuario_id))
  end

  def horas_trabalhadas_aprovadas(inicio, fim, usuario_id)
    string_hora(calcula_minutos_trabalhados(true, inicio, fim, usuario_id))
  end

  #horas que faltam trabalhar
  def horas_restantes(inicio, fim, usuario)
    string_hora(calcula_minutos_restantes(inicio, fim, usuario))
  end

  def horas_a_fazer_por_dia(inicio, fim, usuario_id)
    dias = calcula_dias_uteis_restantes(fim, usuario_id)
    if dias == 0
      string_hora(0)
    else
      string_hora(calcula_minutos_restantes(inicio, fim, usuario_id) / dias)
    end
  end

  def horas_ausencias_abonadas(inicio, fim, usuario_id)
    string_hora(Ausencia.joins(:dia).where(abonada: true, dia: {data: inicio..fim, usuario_id: usuario_id}).sum(:horas)/60)
  end

  def horas_contratadas(data, usuario_id)
    Usuario.find(usuario_id).horario_data(data)
  end
  
  def calcula_horas_trabalhadas(inicio, fim, usuario_id)
    calcula_minutos_trabalhados(true, inicio, fim, usuario_id)/60
  end

  private
  def calcula_minutos_trabalhados(aprovados, inicio, fim, usuario_id)
    if aprovados
      return Atividade.joins(:dia).where(aprovacao: true, dia: {data: inicio..fim, usuario_id: usuario_id}).sum(:duracao)/60 +
        Ausencia.joins(:dia).where(abonada: true, dia: {data: inicio..fim, usuario_id: usuario_id}).sum(:horas)/60
    else
      return Atividade.joins(:dia).where(dia: {usuario_id: usuario_id, data: inicio..fim}).sum(:duracao)/60 + Ausencia.where(:abonada => true).sum(:horas)/60
    end
  end

  def calcula_minutos_restantes(inicio, fim, usuario_id)
    hoje = Date.today
    minutos_ausencias = Ausencia.where(abonada: [true]).collect{|a| a.segundos}.sum/60
    horario_mensal = Usuario.find(usuario_id).contrato_vigente_em(hoje).hora_mes
    min_totais = horario_mensal*60
    min_trabalhados = calcula_minutos_trabalhados(false, inicio, fim, usuario_id)
    return min_totais - min_trabalhados - minutos_ausencias
  end

  #  Recebe o total de minutos e devolve uma string no formato hh:mm
  def string_hora(minutos)
    hh, mm = (minutos).divmod(60)
    if (hh < 0)
      hh = mm = 0
    end
    return ("%02d"%hh).to_s+":"+("%02d"%mm.to_i).to_s
  end
  
  #pode ser ateh o fim do contrato ou do fim do mes
  def calcula_dias_uteis_restantes(fim, usuario_id)
    data = Date.today
    if !Atividade.find_by_data_and_usuario_id(data, current_usuario).nil?
      data = data.next
    end
    #checa se há alguma atividade cadastrada hoje
    #dia_model = self.dias.where('numero = ?', data.day).first
    #if dia_model
    #data = data.next
    #end
    dias_uteis = 0
    d = data
    while (d != fim + 1.day)
      if (!d.sunday? and !d.saturday? and !d.holiday?('br'))
        dias_uteis+= 1
      end
      d = d.next
    end
    #precisa checar as ausencias futuras
    return dias_uteis
  end

end
