class AlterTableWorkonAddPermissaoId < ActiveRecord::Migration
  def change
    add_column :workons, :permissao_id, :integer
  end
end
