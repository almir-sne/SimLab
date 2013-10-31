class RemoveUsuarioIdFromAusencias < ActiveRecord::Migration
  def up
    remove_column :ausencias, :usuario_id
  end

  def down
    add_column :ausencias, :usuario_id  , :integer
    Ausencia.all.each do |a|
      a.usuario = a.mes.usuario
      a.save
    end
  end
end
