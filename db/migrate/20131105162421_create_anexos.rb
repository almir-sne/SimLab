class CreateAnexos < ActiveRecord::Migration
  def change
    create_table :anexos do |t|
      t.string :nome
      t.string :tipo
      t.string :arquivo
      t.integer :usuario_id

      t.timestamps
    end
  end
end
