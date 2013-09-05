class AlterTableTelefoneChangeColumnNumero < ActiveRecord::Migration
  def up
    change_table :telefones do |t|
      t.change :numero, :string
    end
  end

  def down
    change_table :telefones do |t|
      t.change :numero, :integer
    end
  end
end
