class AddAddressAndCelUsuario < ActiveRecord::Migration
  def change
    add_column :usuarios, :address, :text
    add_column :usuarios, :cel,     :string
  end
end
