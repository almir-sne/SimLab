class Dia < ActiveRecord::Base
  attr_accessible :entrada, :intervalo, :mes_id, :numero, :saida, :usuario_id

  belongs_to :usuario, :mes

end
