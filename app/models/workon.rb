class Workon < ActiveRecord::Base
  belongs_to :usuario
  belongs_to :projeto
  has_many :coordenacoes

  validates_presence_of :projeto_id
  validates_presence_of :usuario_id
  validates :usuario_id, :uniqueness => {:scope => :projeto_id}

  accepts_nested_attributes_for :coordenacoes, :allow_destroy => true
  
  #def coordenadores
    #Usuario.joins(:coordenacoes).where(coordenacoes: {workon_id: self.id }).collect {|u| [u.nome, u.id]}
  #end

end
