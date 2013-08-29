class RemoveBancoContaAndAgenciaFromUsuario < ActiveRecord::Migration
  def up
    remove_column :usuarios, :banco
    remove_column :usuarios, :conta
    remove_column :usuarios, :agencia
  end

  def down
    add_column :usuarios, :banco, :string
    add_column :usuarios, :conta, :string
    add_column :usuarios, :agencia, :string
  end
end
