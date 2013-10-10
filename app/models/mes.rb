require 'holidays'
require 'holidays/br'
class Mes < ActiveRecord::Base
  attr_accessible :ano, :numero, :usuario_id, :valor_hora, :id, :pagamentos_attributes
  has_many :atividades
  has_many :dias
  has_many :ausencias
  has_many :pagamentos, :dependent => :destroy
  belongs_to :usuario

  accepts_nested_attributes_for :pagamentos, :allow_destroy => true

  def tem_reprovacao?
    !self.atividades.where("aprovacao is false").blank?
  end

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
  def calcula_minutos_trabalhados(aprovados)
    if aprovados
      return self.atividades.where(:aprovacao => true).sum(:duracao)/60 +
        self.ausencias.where(:abonada => true).sum(:horas)/60
    else
      return self.atividades.sum(:duracao)/60 + self.ausencias.where(:abonada => true).sum(:horas)/60
    end
  end

  def calcula_minutos_restantes
    horario = self.horas_contratadas.blank? ? 0 : self.horas_contratadas
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
    final_do_mes = data.at_end_of_month
    dia_model = self.dias.where('numero = ?', data.day).first
    if dia_model
      data = data.next
    end
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
