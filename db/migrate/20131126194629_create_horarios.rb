class CreateHorarios < ActiveRecord::Migration
  def change
    create_table :horarios do |t|
      t.integer :dia_id
      t.datetime :entrada
      t.datetime :saida

      t.timestamps
    end
  end
end
