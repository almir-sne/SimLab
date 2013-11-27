class ChangeEntradaESaidaFormat < ActiveRecord::Migration
  def up
    Dia.all.each do |dia|
      horario = Horario.new(entrada: dia.entrada, saida: dia.saida, dia_id: dia.id)
      horario.save
    end
  end

  def down
    Horario.destroy_all
  end
end
