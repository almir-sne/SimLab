class ChangeRoleValueOnUsuario < ActiveRecord::Migration
  def up
    Usuario.all.each do |user|
      user.role = "diretor"        if user.role == "coordenador"
      user.role = "usuario normal" if user.role == "desenvolvedor"
      user.save
    end
  end

  def down
    Usuario.all.each do |user|
      user.role = "coordenador"   if user.role == "diretor"
      user.role = "desenvolvedor" if user.role == "usuario normal"
      user.save
    end
  end
end
