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
    if entrada == 0.0 || saida == 0.0
      "0:00"
    else
      hora = (((saida - entrada) - read_attribute(:intervalo)) / 3600).to_i
      minuto = ((((saida - entrada) - read_attribute(:intervalo)) % 3600) / 60).to_i
      hora.to_s + ":" + minuto.to_s.rjust(2, '0')
    end
  end

  def entrada
    entrada_real = self.horarios.minimum(:entrada)
    if self.horarios.nil? or entrada_real.nil?
      0.0
    else
      entrada_real.utc
    end
  end

  def saida
    saida_real = self.horarios.maximum(:saida)
    if self.horarios.nil? or saida_real.nil?
      0.0
    else
      saida_real.utc
    end
  end

  #sim, essa entrada_var é de proósito para não fazer 2 queries no banco
  def entrada_formatada
    entrada_var = self.entrada
    if !entrada_var.nil? and entrada_var != 0.0
      entrada_var.strftime("%H:%M")
    else
      ""
    end
  end
  
  #sim, essa saida_var é de proósito para não fazer 2 queries no banco
  def saida_formatada
    saida_var = self.saida
    if !saida_var.nil? and saida_var != 0.0
      saida_var.strftime("%H:%M")
    end
  end

  def horas
    self.horarios.collect{|h| h.saida - h.entrada}.sum
  end

  def minutos
    ((saida - entrada) - read_attribute(:intervalo)) / 60
  end

  def horas_atividades_formato
    total_minutos_atividade = atividades.where(aprovacao: true).sum(:duracao) / 60
    hh, mm = (total_minutos_atividade).divmod(60)
    ("%02d"%hh).to_s+":"+("%02d"%mm.to_i).to_s
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
    x = 0
    horarios.order(:entrada).each_with_index do |horario, index|
      if horarios[index + 1]
        x += horarios[index + 1].entrada.seconds_since_midnight - horario.saida.seconds_since_midnight
      end
    end
    x
  end

  private
  def validar_horas
    if( saida - entrada - read_attribute(:intervalo)) <= 0
      errors.add(:atividade, "Day has unvalid time")
    end
  end

end
