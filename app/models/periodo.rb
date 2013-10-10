require 'holidays'
require 'holidays/br'
class Periodo
  attr_accessible :ano, :numero, :usuario_id, :valor_hora, :id, :pagamentos_attributes
  has_many :atividades
  has_many :dias
  has_many :ausencias
  has_many :pagamentos, :dependent => :destroy
  belongs_to :usuario

  accepts_nested_attributes_for :pagamentos, :allow_destroy => true
  
  def tem_reprovacao?(inicio, fim, usuario_id)
    !Atividade.where(aprovacao: false, data: inicio..fim, usuario_id: usuario_id).blank?
  end

  def dias_uteis_restantes(fim)
    calcula_dias_uteis_restantes(fim).to_s
  end

  def horas_trabalhadas(inicio, fim, usuario_id)
    string_hora(calcula_minutos_trabalhados(false, inicio, fim, usuario_id))
  end

  def horas_trabalhadas_aprovadas(inicio, fim, usuario_id)
    string_hora(calcula_minutos_trabalhados(true, inicio, fim, usuario_id))
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

  def horas_contratadas
     contrato.hora_mes
  end
  
  def horas_ausencias_abonadas
    string_hora(self.ausencias.where(:abonada => true).sum(:horas)/60)
  end

  def contrato
    usuario.contrato_vigente_em(Date.new(ano, numero, 1))
  end
  
  def calcula_horas_trabalhadas
    calcula_minutos_trabalhados(true)/60
  end

  private
  def calcula_minutos_trabalhados(aprovados, inicio, fim, usuario_id)
    if aprovados
      return Atividade.where(aprovacao: true, data: inicio..fim, usuario_id: usuario_id).sum(:duracao)/60 +
       Ausencia.where(abonada: true, data: inicio..fim, usuario_id: usuario_id).sum(:horas)/60
    else
      return Atividade.where(usuario_id: usuario_id, data: inicio..fim).sum(:duracao)/60 +Ausencia.where(:abonada => true).sum(:horas)/60
    end
  end

  def calcula_minutos_restantes(fim, usuario_id)
    minutos_ausencias = Ausencia.where(:abonada => [false,nil]).collect{|a| a.segundos}.sum/60
    horario = Usuario.find(usuario_id).contrato_vigente_em(Date.today).hora_mes
    min_totais = horario*60
    min_trabalhados = calcula_minutos_trabalhados(false, Date.today, fim, usuario_id)
    return min_totais - min_trabalhados - minutos_ausencias
  end

  #  Recebe o total de minutos e devolve uma string no formato hh:mm
  def string_hora(minutos)
    Time.at(minutos * 60).utc.strftime("%H:%M")
  end

  def calcula_dias_uteis_restantes(fim)
    data = Date.today
    dia_model = self.dias.where('numero = ?', data.day).first
    if dia_model
      data = data.next
    end
    dias_uteis = 0
    d = data
    while (d != fim + 1.day)
      if (!d.sunday? and !d.saturday? and !d.holiday?('br'))
        dias_uteis+= 1
      end
      d = d.next
    end
    return dias_uteis
  end

end
