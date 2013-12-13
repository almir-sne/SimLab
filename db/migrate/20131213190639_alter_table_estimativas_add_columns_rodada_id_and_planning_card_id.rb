class AlterTableEstimativasAddColumnsRodadaIdAndPlanningCardId < ActiveRecord::Migration
  def change
    add_column :estimativas, :rodada_id, :integer
    add_column :estimativas, :planning_card_id, :integer
  end
end
