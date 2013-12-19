class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.text :nome
      t.timestamps
    end
  end
end
