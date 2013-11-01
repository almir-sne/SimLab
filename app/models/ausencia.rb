  class Ausencia < ActiveRecord::Base
  attr_accessible :abonada, :avaliador_id, :horas, :justificativa, :mensagem, :mes_id, 
  :dia_id, :dia
  
  belongs_to :dia
  belongs_to :mes
  belongs_to :avaliador, :class_name => "Usuario"
  
  def self.por_periodo(inicio, fim, usuario_id)
    Ausencia.joins(:dia).where(dia: {data: inicio..fim, usuario_id: usuario_id})
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
