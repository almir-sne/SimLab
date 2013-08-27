class CreateConta < ActiveRecord::Migration
  def change
    create_table :conta do |t|
      t.string :agencia
      t.string :banco
      t.string :numero
      t.integer :usuario_id

      t.timestamps
    end
  end
end
