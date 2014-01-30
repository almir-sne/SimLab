class Coordenacao < ActiveRecord::Base
  belongs_to :workon
  belongs_to :usuario
  
  has_one :projeto, :through => :workon

  validates :usuario_id, :presence=> true, :uniqueness => {:scope => :workon_id}
  
  def coordenador
    self.usuario
  end
  
  def coordenado
    self.workon.usuario
  end
  
end
