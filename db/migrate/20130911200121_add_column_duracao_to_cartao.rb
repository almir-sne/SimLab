class AddColumnDuracaoToCartao < ActiveRecord::Migration
  def change
    add_column :cartaos, :duracao, :integer
  end
end
