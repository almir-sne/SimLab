class Par < ActiveRecord::Base
  belongs_to :par, :class_name => "Usuario"
  
  def minutos
    duracao.blank? ? 0 : duracao/60
  end

  def minutos=(minutos)
    self.duracao = minutos.to_i * 60
  end
end
