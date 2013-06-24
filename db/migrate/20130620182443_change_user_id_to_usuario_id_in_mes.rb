class ChangeUserIdToUsuarioIdInMes < ActiveRecord::Migration
  def up
    rename_column :mes, :user_id, :usuario_id
  end

  def down
    rename_column :mes, :usuario_id, :user_id
  end
end
