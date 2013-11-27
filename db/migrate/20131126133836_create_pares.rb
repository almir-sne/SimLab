class CreatePares < ActiveRecord::Migration
  def change
    create_table :pares do |t|
      t.integer :par_id
      t.integer :atividade_id
      t.float :duracao

      t.timestamps
    end
  end
end
