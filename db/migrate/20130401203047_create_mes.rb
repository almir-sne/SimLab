class CreateMes < ActiveRecord::Migration
  def change
    create_table :mes do |t|
      t.integer :numero
      t.integer :ano
      t.integer :user_id
      t.float :valor_hora
      t.integer :horas_contratadas

      t.timestamps
    end
  end
end
