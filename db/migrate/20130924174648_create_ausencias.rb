class CreateAusencias < ActiveRecord::Migration
  def change
    create_table :ausencias do |t|
      t.integer :usuario_id
      t.integer :mes_id
      t.string :justificativa
      t.boolean :abonada
      t.string :mensagem
      t.integer :avaliador_id
      t.decimal :horas, :precision => 3, :scale => 1
      t.integer :dia

      t.timestamps
    end
  end
end
