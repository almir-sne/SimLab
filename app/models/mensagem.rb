class Mensagem < ActiveRecord::Base
  attr_accessible :atividade_id, :conteudo, :autor_id, :visto

  belongs_to :atividade
  belongs_to :autor, :class_name => "Usuario"
  has_one    :usuario, :through => :atividade
end
