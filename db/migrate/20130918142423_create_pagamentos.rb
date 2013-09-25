class CreatePagamentos < ActiveRecord::Migration
  def change
    create_table :pagamentos do |t|
      t.integer :mes_id
      t.integer :usuario_id
      t.integer :criador_id
      t.decimal :valor
      t.date :data
      t.integer :fonte
      t.string :motivo

      t.timestamps
    end
  end
end
