class Dia < ActiveRecord::Base
  attr_accessible :entrada, :intervalo, :mes_id, :numero, :saida, :usuario_id

  belongs_to :usuario
  belongs_to :mes
  has_many :atividades, :dependent => :destroy

  accepts_nested_attributes_for :atividades, :allow_destroy => true

  attr_accessible :atividades_attributes

  validates :numero, :uniqueness => {:scope => :mes_id}
  validates :mes_id, :presence => true
  validates :usuario_id, :presence => true
#  validate :validar_horas

  def entrada
    read_attribute(:entrada).nil? ? Time.now.in_time_zone('Brasilia') : read_attribute(:entrada).utc
  end

  def saida
    read_attribute(:saida).nil? ? Time.now.in_time_zone('Brasilia') : read_attribute(:saida).utc
  end

  def horas
    ((saida - entrada) - read_attribute(:intervalo)) / 3600
  end

  def minutos
    ((saida - entrada) - read_attribute(:intervalo)) / 60
  end

  def formata_horas
    hora = (((saida - entrada) - read_attribute(:intervalo)) / 3600).to_i
    minuto = ((((saida - entrada) - read_attribute(:intervalo)) % 3600) / 60).to_i
    hora.to_s.rjust(2, '0') + ":" + minuto.to_s.rjust(2, '0')
  end

  def formata_intervalo
    hora = (read_attribute(:intervalo) / 3600).to_i
    minuto = (( read_attribute(:intervalo) % 3600) / 60).to_i
    hora.to_s.rjust(2, '0') + ":" + minuto.to_s.rjust(2, '0')
  end

  def bar_width
    width = horas.nil? ? 0 : (horas * 8)
    if width > 100
      width = 100
    end
    width.to_s + "%"
  end

  def horas_atividades_formato
    total_minutos_atividade = 0

    self.atividades.each do |atividade|
      if atividade.aprovacao
        total_minutos_atividade = total_minutos_atividade + (atividade.minutos.nil? ? 0 : (atividade.minutos))
      end
    end
    hh, mm = (total_minutos_atividade).divmod(60)
    ("%02d"%hh).to_s+":"+("%02d"%mm.to_i).to_s
  end

  def horas_atividades
    retorno = 0
    self.atividades.each do |atividade|

      if atividade.aprovacao
        retorno = retorno + (atividade.horas.nil? ? 0 : atividade.horas.to_i)
      end
    end
    retorno/3600
  end

  def tem_mensagem?
    !self.atividades.where("mensagem is not null").blank?
  end

  def tem_reprovacao?
    !self.atividades.where("aprovacao is false").blank?
  end

  def intervalo
    unless read_attribute(:intervalo).blank?
      Time.new(2000, 1, 1 ,0, 0, 0) + read_attribute(:intervalo)
    else
      Time.new(2000, 1, 1 ,0, 0, 0)
    end
  end

  private
  def validar_horas
    if( saida - entrada - read_attribute(:intervalo)) <= 0
      errors.add(:atividade, "Day has unvalid time")
    end
  end

end
