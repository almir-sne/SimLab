class AddRgAndCursoAndFormadoToUsuario < ActiveRecord::Migration
  def change
    add_column :usuarios, :rg, :string
    add_column :usuarios, :curso, :string
    add_column :usuarios, :formado, :boolean
  end
end
