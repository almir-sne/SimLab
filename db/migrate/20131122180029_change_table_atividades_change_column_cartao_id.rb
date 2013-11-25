class ChangeTableAtividadesChangeColumnCartaoId < ActiveRecord::Migration
  def up
    change_column :atividades, :cartao_id, :integer
  end

  def down
    change_column :atividades, :cartao_id, :string
  end
end
