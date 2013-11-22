class CreateCartoes < ActiveRecord::Migration
  def change
    create_table :cartoes do |t|
      t.float :estimativa
      t.integer :rodada
      t.string :trello_id
      t.timestamps
    end
  end
end
