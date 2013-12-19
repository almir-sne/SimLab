class Atividade < ActiveRecord::Base
  scope :periodo, lambda { |range| where(data: range) if range}
  scope :ano, lambda { |value| where(['extract(year from atividades.data) = ?', value]) if value > 0 }
  scope :mes, lambda { |value| where(['extract(month from atividades.data) = ?', value]) if value > 0 }
  scope :dia, lambda { |value| where(['extract(day from atividades.data) = ?', value]) if value > 0 }
  scope :projeto, lambda { |value| where(['projeto_id = ?', value]) if value > 0 }
  scope :usuario, lambda { |value| where(['usuario_id = ?', value]) if value > 0 }
  scope :aprovacao, lambda {|value|
    if value == 3 or value.nil?
      where('aprovacao is null')
    elsif value == 0 or value == 1
      where(['aprovacao = ?', value])
    end
  }

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

  def horas
    read_attribute(:duracao).blank? ? 0 : read_attribute(:duracao)/60
  end

  def bar_width
    width = duracao.nil? ? "0" : (duracao / 360).to_s
    width + "%"
  end

  def minutos
    duracao/60
  end

  def formata_duracao
    Time.at(duracao).utc.strftime("%H:%M")
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
    self.cartao = Cartao.find_or_create_by_trello_id(cartao_id) unless cartao_id.blank?
  end
end
