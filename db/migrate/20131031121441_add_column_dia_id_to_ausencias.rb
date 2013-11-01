class AddColumnDiaIdToAusencias < ActiveRecord::Migration
  def change
    add_column :ausencias, :dia_id, :integer
  end
end
