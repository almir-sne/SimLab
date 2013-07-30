class Mes < ActiveRecord::Base
  attr_accessible :ano, :horas_contratadas, :numero, :usuario_id, :valor_hora

  has_many :atividades
  has_many :dias

  belongs_to :usuario

  def horas_trabalhadas
    unless usuario_id.nil?
      dias = Dia.find_all_by_mes_id_and_usuario_id(id, usuario_id)
      minutos_map = dias.map{|dia| dia.minutos}
      total = minutos_map.inject{|sum,x| sum + x }.nil? ? 0 : minutos_map.inject{|sum,x| sum + x }
      hh, mm = (total).divmod(60)
      ("%02d"%hh).to_s+":"+("%02d"%mm.to_i).to_s
    else
      "00:00"
    end
  end

  def horas_trabalhadas_aprovadas
    unless usuario_id.nil?
      tarefas = Atividade.where(:usuario_id => usuario_id, :mes_id => id, :aprovacao => true)
      minutos_map = tarefas.map{|tarefa| tarefa.minutos}
      total = minutos_map.inject{|sum,x| sum + x }.nil? ? 0 : minutos_map.inject{|sum,x| sum + x }
      hh, mm = (total).divmod(60)
      ("%02d"%hh).to_s+":"+("%02d"%mm.to_i).to_s
    else
      "00:00"
    end
  end
end
