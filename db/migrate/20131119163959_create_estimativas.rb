class CreateEstimativas < ActiveRecord::Migration
  def change
    create_table :estimativas do |t|
      t.integer :cartao_id
      t.integer :usuario_id
      t.float :estimativa
      t.integer :rodada

      t.timestamps
    end
  end
end
