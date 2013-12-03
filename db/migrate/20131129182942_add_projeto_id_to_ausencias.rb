class AddProjetoIdToAusencias < ActiveRecord::Migration
  def change
    add_column :ausencias, :projeto_id, :integer
  end
end
