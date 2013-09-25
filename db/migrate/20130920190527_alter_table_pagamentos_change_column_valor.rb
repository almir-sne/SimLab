class AlterTablePagamentosChangeColumnValor < ActiveRecord::Migration
  def up
    change_table :pagamentos do |t|
      t.change :valor, :decimal, :precision => 7, :scale => 2
    end
  end

  def down
    change_table :pagamentos do |t|
      t.change :valor, :decimal, :precision => 10
    end
  end
end
