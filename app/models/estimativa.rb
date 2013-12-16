class Estimativa < ActiveRecord::Base
  attr_accessible :cartao_id, :valor, :rodada, :usuario_id, :planning_card_id
  
  belongs_to :usuario
  belongs_to :cartao
  belongs_to :planning_card
end
