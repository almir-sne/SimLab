class Dia < ActiveRecord::Base
  attr_accessible :usuario_id, :data, :intervalo, :entrada, :saida
  
  belongs_to :mes
  belongs_to :usuario
  has_many :atividades, :dependent => :destroy
  has_many :ausencias
  has_many :horarios, :dependent => :destroy

  accepts_nested_attributes_for :atividades, :allow_destroy => true
  accepts_nested_attributes_for :horarios, :allow_destroy => true
  
  attr_accessible :atividades_attributes
  attr_accessible :horarios_attributes

  validates :data, :uniqueness => {:scope => :usuario_id}, :presence => true
  validates :usuario_id, :presence => true
  #  validate :validar_horas

  def self.por_periodo(inicio, fim, usuario_id)
    Dia.where(usuario_id: usuario_id, data: inicio..fim)
  end
  
  def entrada
    horarios_t = self.horarios
    if horarios_t.blank?
      nil
    else
      horarios_t.first.entrada.in_time_zone('UTC')
    end  
    #read_attribute(:entrada).nil? ? Time.now.in_time_zone('Brasilia') : read_attribute(:entrada).in_time_zone('Brasilia')
  end

  def saida
    horarios_t = self.horarios
    if horarios_t.blank?
      nil
    else
      horarios_t.last.saida.in_time_zone('UTC')
    end
    #read_attribute(:saida).nil? ? Time.now.in_time_zone('Brasilia') : read_attribute(:saida).in_time_zone('Brasilia')
  end

  def horas
    ((saida - entrada) - read_attribute(:intervalo)) / 3600
  end

  def minutos
    ((saida - entrada) - read_attribute(:intervalo)) / 60
  end

  def formata_horas
    if (read_attribute(:entrada).blank? || read_attribute(:saida).blank?)
      "0:00"
    else
      hora = (((saida - entrada) - read_attribute(:intervalo)) / 3600).to_i
      minuto = ((((saida - entrada) - read_attribute(:intervalo)) % 3600) / 60).to_i
      hora.to_s + ":" + minuto.to_s.rjust(2, '0')
    end
  end

  def formata_intervalo
    intervalo = read_attribute(:intervalo)
    if (!read_attribute(:intervalo).nil?)
      hora = (read_attribute(:intervalo) / 3600).to_i
      minuto = (( read_attribute(:intervalo) % 3600) / 60).to_i
      hora.to_s.rjust(2, '0') + ":" + minuto.to_s.rjust(2, '0')
    else
      "00:00"
    end
    
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

  def horas_atividades_todas
    hh, mm = (atividades.sum(:duracao)/60).divmod(60)
    hh.to_s+":"+("%02d"%mm.to_i).to_s
  end

  def tem_mensagem?
    self.atividades.where("mensagem is not null").blank?
  end

  def tem_reprovacao?
    !self.atividades.where("aprovacao is false").blank?
  end

  def formata_mensagens
    m = ""
    self.atividades.where("mensagem is not null").each do |a|
      m += "#{a.mensagem}\n"
    end
    m.strip
  end

  def intervalo
    unless read_attribute(:intervalo).blank?
      Time.new(2000, 1, 1 ,0, 0, 0) + read_attribute(:intervalo)
    else
      Time.new(2000, 1, 1 ,0, 0, 0)
    end
  end

  def tem_atividades?
    return 
  end

  private
  def validar_horas
    if( saida - entrada - read_attribute(:intervalo)) <= 0
      errors.add(:atividade, "Day has unvalid time")
    end
  end

end
