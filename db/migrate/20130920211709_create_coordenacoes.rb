class CreateCoordenacoes < ActiveRecord::Migration
  def change
    create_table :coordenacoes do |t|
      t.integer :usuario_id
      t.integer :workon_id

      t.timestamps
    end
  end
end
