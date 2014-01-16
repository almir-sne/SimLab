class CampoDado < ActiveRecord::Base
  belongs_to :campo_projeto
  belongs_to :usuario
  
  validates_presence_of :campo_projeto_id
  validates_presence_of :usuario_id
end