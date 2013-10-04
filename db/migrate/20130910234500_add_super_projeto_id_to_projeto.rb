class AddSuperProjetoIdToProjeto < ActiveRecord::Migration
  def change
    add_column :projetos, :super_projeto_id, :integer
  end
end
