class CreateCampoDado < ActiveRecord::Migration
  def change
    create_table :campo_dados do |t|
      t.integer :campo_projeto_id
      t.text :dado
      t.integer :usuario_id
    end
  end
end
