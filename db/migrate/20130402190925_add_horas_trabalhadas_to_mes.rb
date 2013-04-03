class AddHorasTrabalhadasToMes < ActiveRecord::Migration
  def change
    add_column :mes, :horas_trabalhadas, :integer, :default => 0
  end
end
