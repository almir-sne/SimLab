class Dia < ActiveRecord::Base
  belongs_to :mes
  belongs_to :usuario
  has_many :atividades, :dependent => :destroy
  has_many :ausencias
  has_many :horarios, :dependent => :destroy

  accepts_nested_attributes_for :atividades, :allow_destroy => true
  accepts_nested_attributes_for :horarios, :allow_destroy => true
  validates :data, :uniqueness => {:scope => :usuario_id}, :presence => true
  validates :usuario_id, :presence => true
  #  validate :validar_horas

  def self.por_periodo(inicio, fim, usuario_id)
    Dia.where(usuario_id: usuario_id, data: inicio..fim)
  end

  def formata_horas
    if (entrada.blank? || saida.blank?)
      "0:00"
    else
      hora = (((saida - entrada) - read_attribute(:intervalo)) / 3600).to_i
      minuto = ((((saida - entrada) - read_attribute(:intervalo)) % 3600) / 60).to_i
      hora.to_s + ":" + minuto.to_s.rjust(2, '0')
    end
  end

  def entrada
    if self.horarios.nil? or self.horarios.minimum(:entrada).nil?
      0.0
    else
      self.horarios.minimum(:entrada).utc
    end
  end

  def saida
    if self.horarios.nil? or self.horarios.maximum(:saida).nil?
      0.0
    else
      self.horarios.maximum(:saida).utc
    end
  end

  def entrada_formatada
    if entrada.nil? and entrada != 0.0
      entrada.strftime("%H:%M")
    else
      ""
    end
  end

  def saida_formatada
    if saida.nil? and saida != 0.0
      saida.strftime("%H:%M")
    end
  end

  def horas
    self.horarios.collect{|h| h.saida - h.entrada}.sum
  end

  def minutos
    ((saida - entrada) - read_attribute(:intervalo)) / 60
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
    msgs = ""
    self.atividades.each  do |a|
      a.mensagens.each do |m|
        unless (m.conteudo.nil?)
          msgs += "#{m.conteudo}\n"
        end
      end
    end
    msgs.strip
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
