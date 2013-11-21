class Cartao < ActiveRecord::Base
  attr_accessible :trello_id, :estimativa, :rodada, :id
  belongs_to :usuario
  
  validates :trello_id, :uniqueness => true, :presence => true
end
