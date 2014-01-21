class AlterTableDadosRenameColumnDadoToValor < ActiveRecord::Migration
  def up
    rename_column :dados, :dado, :valor
  end
  
  def down
    rename_column :dados, :valor, :dado
  end
end
