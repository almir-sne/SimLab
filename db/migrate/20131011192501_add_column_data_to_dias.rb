class AddColumnDataToDias < ActiveRecord::Migration
  def change
    add_column :dias, :data, :date
  end
end
