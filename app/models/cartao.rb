class Cartao < ActiveRecord::Base
  validates :trello_id, :uniqueness => true, :presence => true

  scope :tags, lambda { |value| joins(:tags).where(tags: { id: value }) }
  scope :filhos, lambda { |pai|
    if pai == 0
      where{pai_id != nil}
    elsif pai == -1
      where{pai_id == nil}
    else
      where{pai_id == my{pai}}
    end
  }

  has_many :atividades
  has_many :rodadas

  belongs_to :pai, :class_name => "Cartao"
  has_and_belongs_to_many :tags

  accepts_nested_attributes_for :tags

  def horas_trabalhadas
    atividades.sum(:duracao)
  end

  def rodada_aberta?
    !self.rodadas.where(fechada: false).blank?
  end

  def pai_trello_id
    self.pai.try(:trello_id)
  end

  def pai_trello_id=(val)
    self.pai = Cartao.find_or_create_by(trello_id: val)
  end

  def fechar_rodada(user)
    rodada = self.rodadas.where(fechada: false).last
    if rodada
      rodada.fechada = true
      rodada.fim = Time.now
      rodada.finalizador = user
      rodada.save
    end
  end

  def tags_string
    tags.pluck(:nome).join(", ")
  end

  def tags_string=(val)
    self.tags = val.split(",").collect{|t| Tag.find_or_create_by(nome: t.strip)}
  end

  def datas
    datas = self.atividades.order :data
    datas.first.data.to_s.split("-").reverse.join("/") +" a " +
     datas.last.data.to_s.split("-").reverse.join("/")
  end

end
