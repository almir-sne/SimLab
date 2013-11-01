class RemoveColumnMesIdFromAusencias < ActiveRecord::Migration
  def up
    remove_column :ausencias, :mes_id
  end

  def down
    add_column :ausencias, :mes_id ,:integer
    Ausencia.all.each do |a|
        a.mes = Mes.find_or_create_by_usuario_id_and_numero_and_ano(a.dia.usuario.id, a.dia.data.month, a.dia.data.year)
        a.save
    end
  end
end
