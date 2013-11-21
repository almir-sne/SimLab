class ChangeTableEstimativaRenameColumnEstimativa < ActiveRecord::Migration
  def up
    rename_column :estimativas, :estimativa, :valor
  end

  def down
    rename_column :estimativas, :valor, :estimativa
  end
end
