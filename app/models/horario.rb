class Horario < ActiveRecord::Base
  attr_accessible :dia_id, :entrada, :saida
  belongs_to :dia
  
  def entrada
    read_attribute(:entrada).nil? ? Time.now.utc : read_attribute(:entrada).utc
  end

  def saida
    read_attribute(:saida).nil? ? Time.now.utc : read_attribute(:saida).utc
  end
  
end
