class AddValorDaBolsaAndCargaHorariaBolsaFauToUsuario < ActiveRecord::Migration
  def change
    add_column :usuarios, :valor_da_bolsa_fau, :float
    add_column :usuarios, :horas_da_bolsa_fau, :integer
    add_column :usuarios, :funcao, :string
    add_column :usuarios, :data_admissao_fau, :date
    add_column :usuarios, :data_demissao_fau, :date
  end
end
