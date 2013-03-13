class CreateBancoDeHoras < ActiveRecord::Migration
  def change
    create_table :banco_de_horas do |t|
      t.date :data
      t.float :horas
      t.text :observacao
      t.integer :projeto_id
      t.integer :usuario_id

      t.timestamps
    end
  end
end
