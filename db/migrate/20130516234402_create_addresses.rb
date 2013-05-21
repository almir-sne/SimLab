class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :state
      t.string :city
      t.string :bairro
      t.string :street
      t.integer :number
      t.string :cep
      t.string :complemento
      t.integer :usuario_id

      t.timestamps
    end
  end
end
