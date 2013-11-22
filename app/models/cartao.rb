class Cartao < ActiveRecord::Base
  attr_accessible :trello_id, :estimativa, :rodada, :id, :estimado
  validates :trello_id, :uniqueness => true, :presence => true
  
  has_many :estimativas
  
  def rodada_concluida?(rodada)
    if rodada < self.rodada
      true
    elsif rodada == self.rodada and self.estimado?
      true
    else
      false
    end
  end
  
  def media(rodada)
    self.estimativas.where("valor > 0 and rodada = ?", rodada).average(:valor)
  end
  
  def estimativas_na_rodada(rodada)
    self.estimativas.where("valor is not null and rodada = ?", rodada).count
  end
  
  def estimativa_string
    if read_attribute(:estimativa) == -2.0
      "Infinito"
    elsif read_attribute(:estimativa) == -1.0
      "?"
    else
      read_attribute(:estimativa)
    end
  end
  
  def minimo(rodada)
    self.estimativas.where("valor >= 0 and rodada = ?", rodada).minimum(:valor)
  end
  
  def maximo(rodada)
    unless self.estimativas.where(valor: -2.0, rodada: rodada).blank?
      "Infinito"
    else
      self.estimativas.where("valor >= 0 and rodada = ?", rodada).maximum(:valor)
    end
  end
end
