class AddColumnDataToAusencias < ActiveRecord::Migration
  def change
    add_column :ausencias, :data, :date
  end
end
