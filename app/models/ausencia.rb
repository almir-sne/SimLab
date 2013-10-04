class Ausencia < ActiveRecord::Base
  attr_accessible :abonada, :avaliador_id, :dia, :horas, :justificativa, :mensagem, :mes_id, :usuario_id
  
  belongs_to :mes
  belongs_to :usuario
  belongs_to :avaliador, :class_name => "Usuario"
  
  validates :dia, :uniqueness => {:scope => :mes_id}
  
  def data
    Date.new(mes.ano, mes.numero, dia)
  end
  
  def horas=(val)
    shebang = val.split(":")
    write_attribute(:horas, shebang[0].to_i * 3600 + shebang[1].to_i * 60)
  end
  
  def horas
    if read_attribute(:horas).nil?
      h = usuario.horario_data(data)/20 * 3600
    else
      h = read_attribute(:horas)
    end
    Time.at(h).utc.strftime("%H:%M")
  end
  
  def abonada?
    return read_attribute(:abonada) && read_attribute(:horas) != nil && read_attribute(:horas) > 0.0
  end
end
