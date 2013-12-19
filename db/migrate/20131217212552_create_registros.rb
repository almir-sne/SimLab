class CreateRegistros < ActiveRecord::Migration
  def change
    create_table :registros do |t|
      t.text :modificacao
      t.integer :autor_id
      t.integer :atividade_id

      t.timestamps
    end
  end
end
