class CreateRecursos < ActiveRecord::Migration
  def change
    create_table :recursos do |t|
      t.string :origem
      t.integer :mes_id
      t.float :valor

      t.timestamps
    end
  end
end
