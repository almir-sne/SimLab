class ChangeUserIdToUsuarioIdInAtividades < ActiveRecord::Migration
  def up
    rename_column :atividades, :user_id, :usuario_id
  end

  def down
    rename_column :atividades, :usuario_id, :user_id
  end
end
