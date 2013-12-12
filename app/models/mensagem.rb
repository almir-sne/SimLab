class Mensagem < ActiveRecord::Base
  belongs_to :atividade
  belongs_to :autor, :class_name => "Usuario"
  has_one    :usuario, :through => :atividade
end
