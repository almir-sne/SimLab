class CreateUserRoles < ActiveRecord::Migration
  def up
    admin = Permissao.find_by(nome: 'admin')
    coordenador = Permissao.find_by(nome: 'coordenador')
    normal = Permissao.find_by(nome: 'normal')
    Workon.all.each do |w|
      if w.usuario
        if w.usuario.role == 'admin'
          w.permissao = admin
        elsif w.usuario.role == 'coordenador'
          w.permissao = coordenador
        else
          w.permissao = normal
        end
        w.save
      end
    end
  end
  
  def down
    Workon.all.each do |w|
      w.permissao_id = nil
      w.save
    end
  end
end
