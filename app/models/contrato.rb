class Contrato < ActiveRecord::Base
  attr_accessible :contratante, :fim, :funcao, :hora_mes, :inicio, :tipo, :usuario_id, :valor_hora, :dia_inicio_periodo

  def periodo_vigente(data)
    if data.day < dia_inicio_periodo
      inicio_periodo = (data.change(day: dia_inicio_periodo) - 1.month)
      fim_periodo = data.change(day: dia_inicio_periodo) - 1.day
    else
      inicio_periodo = (data.change(day: dia_inicio_periodo))
      fim_periodo = data.change(day: dia_inicio_periodo) - 1.day + 1.month
    end
    inicio_periodo = inicio if inicio_periodo < inicio
    fim_periodo = fim if fim_periodo > fim
    inicio_periodo .. fim_periodo
  end

end
