class ChangeBancodehorasNameToWorkon < ActiveRecord::Migration
  def up
    rename_table :banco_de_horas, :workons
  end

  def down
    rename_table :workons, :banco_de_horas
  end
end
