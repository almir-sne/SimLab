class RenameTableContaToContas < ActiveRecord::Migration
  def change
    rename_table :conta, :contas
  end
end
