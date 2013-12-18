class CreatePlanningCards < ActiveRecord::Migration
  def change
    create_table :planning_cards do |t|
      t.string :nome
      t.float :valor
      t.integer :deck_id

      t.timestamps
    end
  end
end
