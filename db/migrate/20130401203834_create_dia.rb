class CreateDia < ActiveRecord::Migration
  def change
    create_table :dia do |t|
      t.integer :numero
      t.datetime :entrada
      t.datetime :saida
      t.float :intervalo
      t.integer :usuario_id
      t.integer :mes_id

      t.timestamps
    end
  end
end
