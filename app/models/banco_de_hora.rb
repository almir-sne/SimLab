class BancoDeHora < ActiveRecord::Base
  attr_accessible :data, :horas, :observacao, :projeto_id, :usuario_id

end
