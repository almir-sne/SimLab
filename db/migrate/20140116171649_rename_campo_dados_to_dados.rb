class RenameCampoDadosToDados < ActiveRecord::Migration
  def change
    rename_table :campo_dados, :dados
  end
end
