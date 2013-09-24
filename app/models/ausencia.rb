class Ausencia < ActiveRecord::Base
  attr_accessible :abonada, :avaliador_id, :dia, :horas, :justificativa, :mensagem, :mes_id, :usuario_id
  
  belongs_to :mes
  belongs_to :usuario
  belongs_to :avaliador, :class_name => "Usuario"
  
end
