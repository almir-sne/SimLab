class Coordenacao < ActiveRecord::Base
  attr_accessible :usuario_id, :workon_id
  belongs_to :workon
  belongs_to :usuario

  validates :usuario_id, :presence=> true, :uniqueness => {:scope => :workon_id}
end
