class CreatePermissoes < ActiveRecord::Migration
  def change
    create_table :permissoes do |t|
      t.string :nome
      t.timestamps
    end
  end
end
