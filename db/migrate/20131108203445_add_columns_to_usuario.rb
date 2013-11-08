class AddColumnsToUsuario < ActiveRecord::Migration
  def change
    add_column :usuarios, :numero_usp, :integer
    add_column :usuarios, :login_trello, :string
  end
end
