class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.integer :projeto_id
      t.string :board_id

      t.timestamps
    end
  end
end
