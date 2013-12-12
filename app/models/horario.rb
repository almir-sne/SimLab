class Horario < ActiveRecord::Base
  belongs_to :dia
  
  def entrada
    read_attribute(:entrada).nil? ? Time.now.utc : read_attribute(:entrada).utc
  end

  def saida
    read_attribute(:saida).nil? ? Time.now.utc : read_attribute(:saida).utc
  end
  
end
