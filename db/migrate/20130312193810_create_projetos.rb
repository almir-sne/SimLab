class CreateProjetos < ActiveRecord::Migration
  def change
    create_table :projetos do |t|
      t.string :name
      t.datetime :data_de_inicio
      t.text :descricao
      t.float :valor
      t.integer :horas_totais

      t.timestamps
    end
  end
end
