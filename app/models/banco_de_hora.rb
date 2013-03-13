class BancoDeHora < ActiveRecord::Base
  attr_accessible :data, :horas, :observacao, :projeto_id, :usuario_id

  def horas
    horas ||= 0
  end

end
