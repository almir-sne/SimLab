class Atividade < ActiveRecord::Base
  scope :periodo, lambda { |range| where(data: range) if range}
  scope :ano, lambda { |value| where(['extract(year from atividades.data) = ?', value]) if value > 0 }
  scope :mes, lambda { |value| where(['extract(month from atividades.data) = ?', value]) if value > 0 }
  scope :dia, lambda { |value| where(['extract(day from atividades.data) = ?', value]) if value > 0 }
  scope :projeto, lambda { |value| where(['projeto_id = ?', value]) if value > 0 }
  scope :usuario, lambda { |value| where(['usuario_id = ?', value]) if value > 0 }
  scope :cartoes_tagados, lambda { |value| joins(:cartao).merge(Cartao.tags value) if value > 0}
  scope :cartoes_filhos, lambda { |value| joins(:cartao).merge(Cartao.filhos value) if value > -1}
  scope :aprovacao, lambda {|value| where(aprovacao: value) unless value.blank?}

  belongs_to :cartao
  belongs_to :dia
  belongs_to :projeto
  belongs_to :usuario
  belongs_to :avaliador, :class_name => "Usuario"
  has_many :mensagens, :dependent => :destroy

  has_many :pares, :dependent => :destroy
  has_many :registros, :dependent => :destroy

  accepts_nested_attributes_for :pares, :allow_destroy => true
  accepts_nested_attributes_for :mensagens, :allow_destroy => true
  validates :dia_id, :presence => true
  validates :projeto_id, :presence => true
  validates :usuario_id, :presence => true

  def minutos
    duracao.blank? ? 0 : duracao/60
  end

  def minutos=(minutos)
    self.duracao = minutos.to_i * 60
  end

  def cor_status
    if self.aprovacao == true
      "green-background"
    elsif self.aprovacao == false
      "red-background"
    else
      ""
    end
  end

  def trello_id
    self.cartao.blank? ? nil : self.cartao.trello_id
  end

  def trello_id=(cartao_id)
    self.cartao = Cartao.find_or_create_by(trello_id: cartao_id) unless cartao_id.blank?
  end
end
