  class Ausencia < ActiveRecord::Base

  scope :data, lambda { |ano, mes, dia| Ausencia.ano(ano).mes(mes).dia(dia) }
  scope :ano, lambda { |value| joins(:dia).where(['extract(year from data) = ?', value]) if value > 0 }
  scope :mes, lambda { |value| joins(:dia).where(['extract(month from data) = ?', value]) if value > 0 }
  scope :dia, lambda { |value| joins(:dia).where(['extract(day from data) = ?', value]) if value > 0 }
  scope :usuario, lambda { |value| joins(:dia).where(['usuario_id = ?', value]) if value > 0 }
  scope :aprovacao, lambda {|value|
    if value == 3
      where('aprovacao is null')
    elsif value == 0 or value == 1
      where(['aprovacao = ?', value])
    end
  }

  has_one :usuario, :through => :dia
  belongs_to :dia
  belongs_to :projeto
  belongs_to :mes
  belongs_to :avaliador, :class_name => "Usuario"
  has_one    :anexo

  def self.por_periodo(inicio, fim, usuario_id)
    Ausencia.joins(:dia).where(dia: {data: inicio..fim, usuario_id: usuario_id}).order('dias.data ASC')
  end

  def horas=(val)
    shebang = val.split(":")
    write_attribute(:horas, shebang[0].to_i * 3600 + shebang[1].to_i * 60)
  end

  def horas
    Time.at(segundos).utc.strftime("%H:%M")
  end

  def segundos
    if read_attribute(:horas).nil?
      h = dia.usuario.horario_data(dia.data)/20 * 3600
    else
      h = read_attribute(:horas)
    end
  end

  def abonada?
    return read_attribute(:abonada) && read_attribute(:horas) != nil && read_attribute(:horas) > 0.0
  end
end
