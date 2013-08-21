class Mes < ActiveRecord::Base
  attr_accessible :ano, :horas_contratadas, :numero, :usuario_id, :valor_hora, :id
  has_many :atividades
  has_many :dias
  belongs_to :usuario
  
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
    dia = Dia.find_by_mes_id_and_usuario_id_and_numero(self.id, usuario_id, Date.today.day)
    if dia
      string_hora(calcula_media_restante(Date.today))
    else
      string_hora(calcula_media_restante(Date.tomorrow))
    end
  end

  private
  def calcula_minutos_trabalhados(aprovados)
    unless usuario_id.nil?
      if aprovados
        tarefas = Atividade.where(:usuario_id => usuario_id, :mes_id => id, :aprovacao => true)
        minutos_map = tarefas.map{|tarefa| tarefa.minutos}
      else
        dias = Dia.find_all_by_mes_id_and_usuario_id(id, usuario_id)
        minutos_map = dias.collect{|dia| dia.minutos}
      end
    end
    return minutos_map.inject{|sum,x| sum + x }.nil? ? 0 : minutos_map.inject{|sum,x| sum + x }
  end

  def calcula_minutos_restantes
    min_totais = Usuario.find_by_id(usuario_id).horario_mensal*60
    min_trabalhados = calcula_minutos_trabalhados(false)
    return min_totais - min_trabalhados
  end

  def calcula_media_restante(data)
    calcula_minutos_restantes / data.dias_uteis_restantes
  end
  
  #  Recebe o total de minutos e devolve uma string no formato hh:mm
  def string_hora(minutos)
    hh, mm = (minutos).divmod(60)
    if (hh < 0)
      hh = 0
      mm = 0
    end
    return ("%02d"%hh).to_s+":"+("%02d"%mm.to_i).to_s
  end
end