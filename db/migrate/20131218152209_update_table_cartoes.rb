class UpdateTableCartoes < ActiveRecord::Migration
  def up
    remove_column :cartoes, :rodada
    remove_column :cartoes, :estimado
    change_column :cartoes, :estimativa, :string
  end

  def down
    add_column :cartoes, :rodada, :integer
    add_column :cartoes, :estimado, :boolean
    change_column :cartoes, :estimativa, :float
  end
end
