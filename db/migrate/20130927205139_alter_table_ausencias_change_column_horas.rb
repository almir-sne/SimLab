class AlterTableAusenciasChangeColumnHoras < ActiveRecord::Migration
  def up
    change_table :ausencias do |t|
      t.change :horas, :float
    end
  end

  def down
    change_table :ausencias do |t|
      t.change :horas, :decimal, :precision => 3, :scale => 1
    end
  end
end
