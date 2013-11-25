class AddColumnEstimadoToCartao < ActiveRecord::Migration
  def change
    add_column :cartoes, :estimado, :boolean, :default => false
  end
end
