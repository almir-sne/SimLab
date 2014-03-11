class AlterTableWorkonAddColumnMostrarAusenciaAndDataInicio < ActiveRecord::Migration
  def up
    add_column :workons, :mostrar_ausencia, :boolean, default: true
    add_column :workons, :data_inicio, :date, default: Date.today
    Workon.update_all 'data_inicio=created_at'
  end

  def down
    remove_column :workons, :mostrar_ausencia
    remove_column :workons, :data_inicio
  end
end
