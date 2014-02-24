class AddColumnAtivoToProjeto < ActiveRecord::Migration
  def change
    add_column :projetos, :ativo, :boolean
    Projeto.all.each do |p|
      p.ativo = true
      p.save
    end
  end
end
