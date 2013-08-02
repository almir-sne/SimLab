class Dia < ActiveRecord::Base
  attr_accessible :entrada, :intervalo, :mes_id, :numero, :saida, :usuario_id, :intervalo_time

  belongs_to :usuario
  belongs_to :mes
  has_many :atividades, :dependent => :destroy

  accepts_nested_attributes_for :atividades

  attr_accessible :atividades_attributes

  validates :numero, :uniqueness => {:scope => :mes_id}
  validates :mes_id, :presence => true
  validates :usuario_id, :presence => true
  validate :validar_horas

  def intervalo_time
    Time.new(2000,1,1,0,0,0,0) + read_attribute(:intervalo)
  end

  def horas
    ((saida - entrada) - read_attribute(:intervalo)) / 3600
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
    total_horas_atividade = 0
    total_minutos_atividade = 0

    self.atividades.each do |atividade|

      if atividade.aprovacao
        total_horas_atividade = total_horas_atividade + (atividade.horas.nil? ? 0 : (atividade.horas/3600)).to_i
        total_minutos_atividade = total_minutos_atividade + (atividade.horas.nil? ? 0 : ((atividade.horas % 3600) / 60)).to_i
      end
    end
    total_horas_atividade.to_s.rjust(2, '0') + ":" + total_minutos_atividade.to_s.rjust(2, '0')
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

  def intervalo
    aux_h = 0
    aux_m = 0
    unless read_attribute(:intervalo).nil?
      aux_h = (read_attribute(:intervalo). / 3600).to_i
      aux_m = ((read_attribute(:intervalo).%3600)/60).to_i
    end
    Time.new(2000, 1, 1 ,aux_h, aux_m, 0)
  end

  private
    def validar_horas
      if( saida - entrada - read_attribute(:intervalo)) <= 0
        errors.add(:atividade, "Day has unvalid time")
      end
    end

end
