class RemoveMesId < ActiveRecord::Migration
  def up
     remove_column :pagamentos, :mes_id
     remove_column :dias, :mes_id
     remove_column :atividades, :mes_id
  end

  def down
     add_column :pagamentos, :mes_id, :integer
     add_column :dias, :mes_id, :integer
     add_column :atividades, :mes_id, :integer
  end
end
