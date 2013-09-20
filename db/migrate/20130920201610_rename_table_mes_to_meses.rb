class RenameTableMesToMeses < ActiveRecord::Migration
  def change
    rename_table :mes, :meses
  end
end
