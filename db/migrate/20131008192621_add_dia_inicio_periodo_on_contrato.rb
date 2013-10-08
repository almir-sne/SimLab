class AddDiaInicioPeriodoOnContrato < ActiveRecord::Migration
  def change
    add_column :contratos, :dia_inicio_periodo, :tinyint
  end
end
