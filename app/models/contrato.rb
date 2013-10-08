class Contrato < ActiveRecord::Base
  attr_accessible :contratante, :fim, :funcao, :hora_mes, :inicio, :tipo, :usuario_id, :valor_hora, :dia_inicio_periodo

  def periodo_vigente(data)
   dia_corrente = data.day
   intervalo_data = data + (dia_corrente - dia_inicio_periodo).day
   if dia_corrente >= dia_inicio_periodo
    (intervalo_data)..(intervalo_data + 1.month)
   else
    (intervalo_data - 1.month)..(intervalo_data)
   end
  end

end
