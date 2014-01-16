class CampoProjeto < ActiveRecord::Base
  belongs_to :projeto
  
  has_many :campo_dados
   
  validates_presence_of :projeto_id

end