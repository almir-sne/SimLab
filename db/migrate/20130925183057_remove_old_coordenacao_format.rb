class RemoveOldCoordenacaoFormat < ActiveRecord::Migration
  def up
   remove_column :workons, :coordenador
  end
  
  #TODO: arrumar migration

  def down
    add_column :workons, :coordenador, :boolean, :default => false
    Coordenacao.all.each do |c|
      user_id = c.usuario_id
      w = Workon.find(c.workon_id)
      z = Workon.find_or_create_by_usuario_id_and_projeto_id(user_id,w.projeto_id)
      z.coordenador = true
      z.save
    end
  end
end
