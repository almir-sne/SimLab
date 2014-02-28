class AlterTableProjetosAddColumnsTagsAndPai < ActiveRecord::Migration
  def up
    add_column :projetos, :tags_obrigatorio, :boolean, default: false
    add_column :projetos, :pai_obrigatorio, :boolean, default: false
  end

  def down
    remove_column :projetos, :tags_obrigatorio
    remove_column :projetos, :pai_obrigatorio
  end
end
