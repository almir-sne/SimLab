class Atividade < ActiveRecord::Base
  attr_accessible :dia_id, :observacao, :mes_id, :projeto_id, :usuario_id, :aprovacao, :mensagem, :avaliador_id
  attr_accessible :aprovado, :reprovado, :duracao, :data

  belongs_to :mes
  belongs_to :dia
  belongs_to :projeto
  belongs_to :usuario
  belongs_to :avaliador, :class_name => "Usuario"
  has_many :cartaos, :dependent => :destroy

  validates :dia_id, :presence => true
  validates :mes_id, :presence => true
  validates :projeto_id, :presence => true
  validates :usuario_id, :presence => true
  validates :horas, :exclusion => {:in => 0..1}

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
    aux_h = 0
    aux_m = 0
    retorno = "0:0"
    if !duracao.nil?
      aux_h = (duracao / 3600).to_i

      aux_m = ((duracao%3600)/60).to_i

      retorno = aux_h.to_s + ":"
      if aux_h < 10
        retorno = "0" + retorno
      end

      if aux_m < 10
        retorno = retorno + "0"
      end
      retorno = retorno + aux_m.to_s
    end

    retorno
  end

end
