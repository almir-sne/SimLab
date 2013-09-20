class Workon < ActiveRecord::Base
  attr_accessible :projeto_id, :usuario_id, :coordenador

  belongs_to :usuario
  belongs_to :projeto
  has_many :coordenacoes

  validates_presence_of :projeto_id
  validates_presence_of :usuario_id
  validates :usuario_id, :uniqueness => {:scope => :projeto_id}

end
