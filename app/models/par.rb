class Par < ActiveRecord::Base
  attr_accessible :duracao, :par_id, :atividade_id
  
  belongs_to :par, :class_name => "Usuario"
  
  def horas
    unless read_attribute(:duracao).blank?
      read_attribute(:duracao)/60
    else
      0
    end
  end

end
