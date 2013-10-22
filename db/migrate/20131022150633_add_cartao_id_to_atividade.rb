class AddCartaoIdToAtividade < ActiveRecord::Migration
  def change
    add_column :atividades, :cartao_id, :string
  end
end
