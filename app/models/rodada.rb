class Rodada < ActiveRecord::Base
  attr_accessible :cartao_id, :criador_id, :deck_id, :fim, :finalizador_id, :inicio, :numero, :fechada
  
  belongs_to :cartao
  belongs_to :deck
  belongs_to :finalizador, :class_name => "Usuario"
  belongs_to :criador, :class_name => "Usuario"
  
  has_many :estimativas
  
  def media
    self.estimativas.where("valor > 0").average(:valor)
  end
  
  def minimo
#    self.estimativas.where("valor is not null").minimum(:valor)
  end
  
  def maximo
#    unless self.estimativas.where(valor: -2.0, rodada: rodada).blank?
#      "Infinito"
#    else
#      self.estimativas.where("valor >= 0 and rodada = ?", rodada).maximum(:valor)
#    end
  end
end
