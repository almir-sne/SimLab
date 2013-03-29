class BancoDeHora < ActiveRecord::Base
  attr_accessible :data, :horas, :observacao, :projeto_id, :usuario_id
  
  belongs_to :usuario
  belongs_to :projeto
  
  validates_presence_of :projeto_id
  validates_presence_of :usuario_id
  
  delegate :nome, :to => :project, :prefix => true
  delegate :nome, :to => :user, :prefix => true
  
end
