class Horario < ActiveRecord::Base
  attr_accessible :dia_id, :entrada, :saida
  
  belongs_to :dia
end
