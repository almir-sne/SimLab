class Atividade < ActiveRecord::Base
  attr_accessible :dia_id, :horas, :observacao, :mes_id, :projeto_id, :user_id

	belongs_to :mes
	belongs_to :dia
end
