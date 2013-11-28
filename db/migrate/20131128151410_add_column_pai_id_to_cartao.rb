class AddColumnPaiIdToCartao < ActiveRecord::Migration
  def change
    add_column :cartoes, :pai_id, :integer
  end
end
