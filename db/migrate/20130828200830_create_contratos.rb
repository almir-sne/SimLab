class CreateContratos < ActiveRecord::Migration
  def change
    create_table :contratos do |t|
      t.date :inicio
      t.date :fim
      t.decimal :valor_hora, :precision => 5, :scale => 2
      t.integer :hora_mes
      t.integer :usuario_id
      t.string :tipo
      t.string :contratante
      t.string :funcao

      t.timestamps
    end
  end
end
