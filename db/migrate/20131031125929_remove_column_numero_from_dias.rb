class RemoveColumnNumeroFromDias < ActiveRecord::Migration
  def up
    remove_column :dias, :numero
  end

  def down
    add_column :dias, :numero, :integer
  end
end
