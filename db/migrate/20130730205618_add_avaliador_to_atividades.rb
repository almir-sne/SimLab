class AddAvaliadorToAtividades < ActiveRecord::Migration
  def change
    add_column :atividades, :avaliador_id, :integer
  end
end
