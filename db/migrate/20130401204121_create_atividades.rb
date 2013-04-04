class CreateAtividades < ActiveRecord::Migration
  def change
    create_table :atividades do |t|
      t.integer :projeto_id
      t.float :horas
      t.integer :user_id
      t.text :observacao
      t.integer :mes_id
      t.integer :dia_id
      t.boolean :aprovacao

      t.timestamps
    end
  end
end
