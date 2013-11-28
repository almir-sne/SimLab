class ChangeEntradaESaidaFormat < ActiveRecord::Migration
  def up
    Dia.all.each do |dia|
      horario = Horario.new
      horario.entrada = dia[:entrada]
      horario.saida = dia[:saida]
      horario.dia_id = dia.id
      horario.save
    end
  end

  def down
    Horario.destroy_all
  end
end
