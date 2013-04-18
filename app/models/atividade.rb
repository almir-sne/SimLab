class Atividade < ActiveRecord::Base
  attr_accessible :dia_id, :horas, :mes_id, :observacao, :projeto_id, :user_id

	belongs_to :mes
	belongs_to :dia
end
