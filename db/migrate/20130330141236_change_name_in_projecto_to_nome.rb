class ChangeNameInProjectoToNome < ActiveRecord::Migration
  def up
    rename_column :projetos, :name, :nome
  end

  def down
    rename_column :projetos, :nome, :name
  end
end
