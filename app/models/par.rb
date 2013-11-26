class Par < ActiveRecord::Base
  attr_accessible :duracao, :par_id, :atividade_id
  
  belongs_to :par, :class_name => "Usuario"

end
