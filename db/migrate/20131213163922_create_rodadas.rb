class CreateRodadas < ActiveRecord::Migration
  def change
    create_table :rodadas do |t|
      t.integer :cartao_id
      t.datetime :inicio
      t.datetime :fim
      t.integer :deck_id
      t.integer :criador_id
      t.integer :finalizador_id
      t.integer :numero
      t.boolean :fechada

      t.timestamps
    end
  end
end
