class DestroyOldEntradaESaidaFormat < ActiveRecord::Migration
  def up
    remove_column :dias, :entrada
    remove_column :dias, :saida
  end

  def down
    add_column :dias, :entrada, :datetime
    add_column :dias, :saida, :datetime
    
    Horario.all.each do |h|
      dia = h.dia
      dia.entrada = h.entrada
      dia.saida = h.saida
      dia.save
    end
  end
  
end
