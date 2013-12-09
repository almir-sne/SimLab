class Contrato < ActiveRecord::Base
  attr_accessible :contratante, :fim, :funcao, :hora_mes, :inicio, :tipo, :usuario_id, :valor_hora, :dia_inicio_periodo
  after_initialize :init

  def init
    self.dia_inicio_periodo  ||= 1           #will set the default value only if it's nil
    self.inicio ||= Date.new(2013,01,01)
    self.fim ||= Date.new(2013,12,31)
  end

  def periodo_vigente(data)
    dia_inicio_local = self.dia_inicio_periodo
    if dia_inicio_local.blank?
      dia_inicio_local = 1
    end
    if data.day < dia_inicio_local
      inicio_periodo = data.change(day: dia_inicio_local) - 1.month
      fim_periodo = data.change(day: dia_inicio_local) - 1.day
    else
      inicio_periodo = data.change(day: dia_inicio_local)
      fim_periodo = data.change(day: dia_inicio_local) + 1.month - 1.day
    end
    inicio_periodo = inicio if inicio_periodo < inicio
    fim_periodo = fim if fim_periodo > fim
    inicio_periodo .. fim_periodo
  end

  def atividades_no_periodo(periodo)
    Atividade.where(:usuario_id => usuario_id).where{(data >= periodo.first) & (data < periodo.last)}
  end

  def atividades
    Atividade.where(data: (inicio .. fim), usuario_id: usuario_id)
  end

  def periodos
    resposta = Array.new
    i = 0
    periodo = periodo_vigente(inicio + i.month)
    while periodo.last > periodo.first do
      resposta << periodo
      i += 1
      periodo = periodo_vigente(inicio + i.month)
    end
    resposta
  end

  def periodos_por_ano(ano)
    resposta = Array.new
    i = 0
    periodo = periodo_vigente(self.inicio + i.month)
    while periodo.last > periodo.first do
      if periodo.first.year == ano or periodo.last.year == ano
        resposta << periodo
      end
      i += 1
      periodo = periodo_vigente(self.inicio + i.month)
      if (periodo.first.year > ano)
        break
      end
    end
    resposta
  end

end
