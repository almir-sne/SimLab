class ChangeOrigemFormatInRecursos < ActiveRecord::Migration
  def up
    change_column :recursos, :origem, :integer
    rename_column :recursos, :origem, :origem_id
  end

  def down
    change_column :recursos, :origem_id, :string
    rename_column :recursos, :origem_id, :origem
  end
end
