class CreateCartaos < ActiveRecord::Migration
  def change
    create_table :cartaos do |t|
      t.string :cartao_id
      t.integer :atividade_id

      t.timestamps
    end
  end
end
