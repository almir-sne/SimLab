class AddCoordenadorOnWorkon < ActiveRecord::Migration
  def change
    add_column :workons, :coordenador, :boolean
  end
end
