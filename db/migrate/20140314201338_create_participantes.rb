class CreateParticipantes < ActiveRecord::Migration
  def change
    create_table :participantes do |t|
      t.integer :reuniao_id
      t.integer :usuario_id
      t.integer :duracao
      t.timestamps
    end
  end
end
