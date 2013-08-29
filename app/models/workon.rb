class Workon < ActiveRecord::Base
  attr_accessible :projeto_id, :usuario_id, :coordenador

  belongs_to :usuario
  belongs_to :projeto

  validates_presence_of :projeto_id
  validates_presence_of :usuario_id

end
