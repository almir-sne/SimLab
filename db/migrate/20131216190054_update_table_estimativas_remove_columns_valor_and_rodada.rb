class UpdateTableEstimativasRemoveColumnsValorAndRodada < ActiveRecord::Migration
  def up
    remove_column :estimativas, :valor
    remove_column :estimativas, :rodada
  end

  def down
    add_column :estimativas, :valor, :float
    add_column :estimativas, :rodada, :integer
  end
end
