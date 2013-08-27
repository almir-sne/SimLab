class CreateTelefones < ActiveRecord::Migration
  def change
    create_table :telefones do |t|
      t.integer :ddd
      t.integer :numero
      t.integer :usuario_id

      t.timestamps
    end
  end
end
