class CampoProjeto < ActiveRecord::Base
  belongs_to :projeto
   
  validates_presence_of :projeto_id

end