class CreateOrigems < ActiveRecord::Migration
  def change
    create_table :origems do |t|
      t.string :nome

      t.timestamps
    end
  end
end
