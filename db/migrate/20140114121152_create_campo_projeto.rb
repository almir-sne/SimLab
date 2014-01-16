class CreateCampoProjeto < ActiveRecord::Migration
  def change
    create_table :campo_projetos do |t|
      t.text :nome
      t.integer :tipo
      t.text :formato
      t.integer :projeto_id
      
      t.timestamps
    end
  end
end
