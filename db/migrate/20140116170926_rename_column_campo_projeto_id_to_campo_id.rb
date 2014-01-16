class RenameColumnCampoProjetoIdToCampoId < ActiveRecord::Migration
  def change
    rename_column :campo_dados, :campo_projeto_id, :campo_id
  end
end
