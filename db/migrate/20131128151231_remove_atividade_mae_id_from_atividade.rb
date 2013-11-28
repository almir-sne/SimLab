class RemoveAtividadeMaeIdFromAtividade < ActiveRecord::Migration
  def up
    remove_column :atividades, :atividade_mae_id
  end

  def down
    add_column :atividades, :atividade_mae_id, :integer
  end
end
