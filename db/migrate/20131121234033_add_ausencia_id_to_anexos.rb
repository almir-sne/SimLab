class AddAusenciaIdToAnexos < ActiveRecord::Migration
  def change
    add_column :anexos, :ausencia_id, :integer
  end
end
