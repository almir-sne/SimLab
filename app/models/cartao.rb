class Cartao < ActiveRecord::Base
  attr_accessible :atividade_id, :card_id
  belongs_to :atividade
end
