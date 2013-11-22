class DropTableCartoes < ActiveRecord::Migration
  def up
    drop_table :cartoes
  end

  def down
    create_table :cartoes do |t|
      t.string :cartao_id
      t.integer :atividade_id
      t.integer :duracao
      t.timestamps
    end
  end
end
