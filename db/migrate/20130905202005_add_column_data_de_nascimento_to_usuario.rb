class AddColumnDataDeNascimentoToUsuario < ActiveRecord::Migration
  def change
    add_column :usuarios, :data_de_nascimento, :date
  end
end
