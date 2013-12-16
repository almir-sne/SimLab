class Rodada < ActiveRecord::Base
  attr_accessible :cartao_id, :criador_id, :deck_id, :fim, :finalizador_id, :inicio, :numero, :fechada
  
  belongs_to :cartao
  belongs_to :deck
  belongs_to :finalizador, :class_name => "Usuario"
  belongs_to :criador, :class_name => "Usuario"
  
  has_many :estimativas
  
  has_many :planning_cards, :through => :estimativas
  
  def media
    self.planning_cards.where("planning_cards.valor is not null").average(:valor).to_f.round 2
  end
  
  def minimo
   (self.planning_cards.where(id: self.deck.minimum.try(:id)).first.try(:nome) ||
     self.planning_cards.where("planning_cards.valor is not null").minimum(:valor))
  end
  
  def maximo
    (self.planning_cards.where(id: self.deck.maximum.try(:id)).first.try(:nome) ||
     self.planning_cards.where("planning_cards.valor is not null").maximum(:valor))
  end
end
