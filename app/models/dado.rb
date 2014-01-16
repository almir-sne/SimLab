class Dado < ActiveRecord::Base
  belongs_to :campo
  belongs_to :usuario
  
  validates_presence_of :campo_id
  validates_presence_of :usuario_id
end
