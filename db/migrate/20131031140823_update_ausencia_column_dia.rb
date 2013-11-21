class UpdateAusenciaColumnDia < ActiveRecord::Migration
  def up
    Ausencia.all.each do |a|
      a.dia = Dia.find_or_create_by_data_and_usuario_id(
      Date.new(a.mes.ano, a.mes.numero, a[:dia]), 
      a.usuario.id
      )
      a.save
    end
  end

  def down
    Ausencia.all.each do |a|
      a.dia = nil
      a.save
    end
  end
end
