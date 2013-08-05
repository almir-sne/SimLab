class ChangeHorasToDuracaoInAtividades < ActiveRecord::Migration
  def up
    rename_column :atividades, :horas, :duracao
  end

  def down
    rename_column :atividades, :duracao, :horas
  end
end
