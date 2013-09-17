class RemoveHorasContratadasFromMes < ActiveRecord::Migration
  def up
    remove_column :mes, :horas_contratadas
  end

  def down
    add_column :mes, :horas_contratadas, :integer
  end
end
