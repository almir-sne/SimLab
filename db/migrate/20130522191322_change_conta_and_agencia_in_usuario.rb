class ChangeContaAndAgenciaInUsuario < ActiveRecord::Migration
  def change
    change_column :usuarios, :conta, :string
    change_column :usuarios, :agencia, :string
  end
end
