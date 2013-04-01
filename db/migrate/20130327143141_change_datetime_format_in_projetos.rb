class ChangeDatetimeFormatInProjetos < ActiveRecord::Migration
  def up
    change_column :projetos, :data_de_inicio, :date
  end

  def down
    change_column :projetos, :data_de_inicio, :datetime
  end
end
