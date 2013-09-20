class AlterTablePagamentosChangeColumnFonte < ActiveRecord::Migration
  def up
    change_table :pagamentos do |t|
      t.change :fonte, :string
    end
  end

  def down
    change_table :pagamentos do |t|
      t.change :fonte, :integer
    end
  end
end
