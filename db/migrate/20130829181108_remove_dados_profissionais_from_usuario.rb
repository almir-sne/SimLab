class RemoveDadosProfissionaisFromUsuario < ActiveRecord::Migration
  def up
    Usuario.all.each do |u|
      Contrato.new(:inicio => u.data_admissao_fau, :fim => u.data_demissao_fau, :usuario_id => u.id,
        :hora_mes => u.horario_mensal, :valor_hora => u.valor_da_hora, :funcao => u.funcao).save
    end
    remove_column :usuarios, :data_admissao_fau
    remove_column :usuarios, :data_demissao_fau
    remove_column :usuarios, :horario_mensal
    remove_column :usuarios, :valor_da_hora
    remove_column :usuarios, :funcao
    remove_column :usuarios, :horas_da_bolsa_fau
    remove_column :usuarios, :valor_da_bolsa_fau
  end

  def down
    add_column :usuarios, :data_admissao_fau, :date
    add_column :usuarios, :data_demissao_fau, :date
    add_column :usuarios, :horario_mensal, :integer
    add_column :usuarios, :valor_da_hora, :float
    add_column :usuarios, :funcao, :string
    add_column :usuarios, :horas_da_bolsa_fau, :integer
    add_column :usuarios, :valor_da_bolsa_fau, :float
    Usuario.all.each do |u|
      c = Contrato.last
      u.data_admissao_fau = c.inicio
      u.data_demissao_fau = c.fim
      u.horario_mensal = c.hora_mes
      u.valor_da_hora = c.valor_hora
      u.funcao = c.funcao
      u.save
      c.destroy
    end
  end
end
