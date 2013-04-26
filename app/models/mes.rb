class Mes < ActiveRecord::Base
  attr_accessible :ano, :horas_contratadas, :numero, :user_id, :valor_hora

  has_many :atividades
  has_many :dias

  belongs_to :usuario

  def horas_trabalhadas
    unless user_id.nil?
      tarefas = Atividade.find_all_by_mes_id_and_user_id(id, user_id)
      horas = tarefas.map{|tarefa| tarefa.horas}
      total = horas.inject{|sum,x| sum + x }.nil? ? 0 : horas.inject{|sum,x| sum + x }/3600
    else
      0
    end

  end

end
