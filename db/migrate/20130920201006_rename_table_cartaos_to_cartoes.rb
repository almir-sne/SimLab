class RenameTableCartaosToCartoes < ActiveRecord::Migration
  def change
    rename_table :cartaos, :cartoes
  end
end
