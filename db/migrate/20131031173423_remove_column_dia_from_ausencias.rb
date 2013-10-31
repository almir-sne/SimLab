class RemoveColumnDiaFromAusencias < ActiveRecord::Migration
  def up
    remove_column :ausencias, :dia
  end

  def down
    add_column :ausencias, :dia ,:integer
    Ausencia.all.each do |a|
      a[:dia] = a.dia.data.day
      a.save
    end
  end
end
