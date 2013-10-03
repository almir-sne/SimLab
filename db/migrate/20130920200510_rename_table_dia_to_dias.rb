class RenameTableDiaToDias < ActiveRecord::Migration
  def change
    rename_table :dia, :dias
  end
end
