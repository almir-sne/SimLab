class RenameCampoProjetosToCampos < ActiveRecord::Migration
  def change
    rename_table :campo_projetos, :campos
  end
end
