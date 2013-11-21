class RemoveColumnDataFromAusencias < ActiveRecord::Migration
  def up
    remove_column :ausencias, :data
  end

  def down
    add_column :ausencias, :data ,:date
    Ausencia.all.each do |a|
        a.data = a.dia.data
        a.save
    end
  end
  
end
