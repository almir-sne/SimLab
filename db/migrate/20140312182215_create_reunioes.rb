class CreateReunioes < ActiveRecord::Migration
  def change
    create_table :reunioes do |t|
      t.integer :projeto_id
      t.integer :criador_id
      t.datetime :inicio
      t.boolean :concluida

      t.timestamps
    end
  end
end
