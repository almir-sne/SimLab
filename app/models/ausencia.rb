  class Ausencia < ActiveRecord::Base
  attr_accessible :abonada, :avaliador_id, :horas, :mes, :justificativa, :mensagem, :mes_id, 
  :dia_id
  
  belongs_to :dia
  belongs_to :mes
  belongs_to :avaliador, :class_name => "Usuario"
  
  def self.por_periodo(inicio, fim, usuario_id)
    Ausencia.where(usuario_id: usuario_id, data: inicio..fim)
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
      h = usuario.horario_data(data)/20 * 3600
    else
      h = read_attribute(:horas)
    end
  end
  
  def abonada?
    return read_attribute(:abonada) && read_attribute(:horas) != nil && read_attribute(:horas) > 0.0
  end
end
