class Atividade < ActiveRecord::Base
  attr_accessible :dia_id, :observacao, :mes_id, :projeto_id, :usuario_id, :aprovacao, :mensagem, :avaliador_id
  attr_accessible :aprovado, :reprovado, :duracao, :data

  belongs_to :mes
  belongs_to :dia
  belongs_to :projeto
  belongs_to :usuario
  belongs_to :avaliador, :class_name => "Usuario"
  has_many :cartoes, :dependent => :destroy

  validates :dia_id, :presence => true
  validates :mes_id, :presence => true
  validates :projeto_id, :presence => true
  validates :usuario_id, :presence => true

  def horas
    unless read_attribute(:duracao).blank?
      read_attribute(:duracao)/60
    else
      0
    end
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

end
