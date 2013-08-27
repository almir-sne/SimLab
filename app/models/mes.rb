require 'holidays'
require 'holidays/br'
class Mes < ActiveRecord::Base
  attr_accessible :ano, :horas_contratadas, :numero, :usuario_id, :valor_hora, :id
  has_many :atividades
  has_many :dias
  belongs_to :usuario

  def dias_uteis_restantes
    calcula_dias_uteis_restantes.to_s 
  end

  def horas_trabalhadas
    string_hora(calcula_minutos_trabalhados(false))
  end

  def horas_trabalhadas_aprovadas
    string_hora(calcula_minutos_trabalhados(true))
  end

  def horas_restantes
    string_hora(calcula_minutos_restantes)
  end

  def horas_a_fazer_por_dia
    dias = calcula_dias_uteis_restantes 
    if dias == 0
      string_hora(0)
    else
      string_hora(calcula_minutos_restantes / dias)
    end
  end

  private
  def calcula_minutos_trabalhados(aprovados)
    if aprovados
      tarefas = self.atividades.where(aprovacao: 'true')
      minutos_map = tarefas.map{|tarefa| tarefa.minutos}
    else
      dias = self.dias 
      minutos_map = dias.collect{|dia| dia.minutos}
    end
  return minutos_map.inject{|sum,x| sum + x }.nil? ? 0 : minutos_map.inject{|sum,x| sum + x }
  end

  def calcula_minutos_restantes
    horario = self.usuario.horario_mensal
    if horario.blank? 
      return 0
    end
    min_totais = horario*60
    min_trabalhados = calcula_minutos_trabalhados(false)
    return min_totais - min_trabalhados
  end

  #  Recebe o total de minutos e devolve uma string no formato hh:mm
  def string_hora(minutos)
    hh, mm = (minutos).divmod(60)
    if (hh < 0)
      hh = mm = 0
    end
    return ("%02d"%hh).to_s+":"+("%02d"%mm.to_i).to_s
  end

  def calcula_dias_uteis_restantes
    data = Date.today
    dia_model = self.dias.where('numero = ?', data.day).first
    if dia_model
      data = data.next
    end
    final_do_mes = data.at_end_of_month
    dias_uteis = 0
    d = data
    while (d != final_do_mes + 1.day)
      if (!d.sunday? and !d.saturday? and !d.holiday?('br'))
        dias_uteis+= 1
      end
      d = d.next
    end
    return dias_uteis
  end

end
