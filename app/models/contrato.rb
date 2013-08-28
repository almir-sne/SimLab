class Contrato < ActiveRecord::Base
  attr_accessible :contratante, :fim, :funcao, :hora_mes, :inicio, :tipo, :usuario_id, :valor_hora
end
