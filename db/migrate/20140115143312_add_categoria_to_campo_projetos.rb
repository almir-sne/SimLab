class AddCategoriaToCampoProjetos < ActiveRecord::Migration
  def change
    add_column :campo_projetos, :categoria, :string
  end
end
