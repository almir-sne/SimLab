class AddColumnAtividadeMaeToAtividades < ActiveRecord::Migration
  def change
    add_column :atividades, :atividade_mae_id, :integer
  end
end
