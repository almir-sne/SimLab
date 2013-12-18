class CreateDecks < ActiveRecord::Migration
  def change
    create_table :decks do |t|
      t.string :nome
      t.integer :minimum_id
      t.integer :maximum_id
      t.timestamps
    end
  end
end
