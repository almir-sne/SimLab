class Workon < ActiveRecord::Base
  belongs_to :usuario
  belongs_to :projeto
  belongs_to :permissao
  has_many :coordenacoes

  validates_presence_of :projeto_id
  validates_presence_of :usuario_id
  validates :usuario_id, :uniqueness => {:scope => :projeto_id}

  accepts_nested_attributes_for :coordenacoes, :allow_destroy => true
  
  after_save :persist_coordenadores

  def persist_coordenadores
    self.coordenacoes << @novos
  end
  
  def coordenadores_ids
    coordenacoes.pluck(:usuario_id)
  end

  def coordenacoes=(coord_array)
    coord_array_antigo = coordenadores_ids
    coord_array_novo = coord_array.collect{|x| !x.blank? ? x.to_i : nil}
    novos = coord_array_novo - coord_array_antigo
    remover = coord_array_antigo - coord_array_novo
    @novos = []
    novos.uniq.each do |usuario_id|
      if (usuario_id)
        if id
          Coordenacao.find_or_create_by(:usuario_id => usuario_id, :workon_id => id)
        else
          @novos << Coordenacao.new(:usuario_id => usuario_id)
        end
      end
    end
    remover.each do |usuario_id|
      if (usuario_id)
        coord = Coordenacao.find_by(:usuario_id => usuario_id, :workon_id => id)
        coord.destroy
      end
    end
  end
end
