class Coordenacao < ActiveRecord::Base
  belongs_to :workon
  belongs_to :usuario

  validates :usuario_id, :presence=> true, :uniqueness => {:scope => :workon_id}
end
