class ChangeToNewCoordenacaoFormat < ActiveRecord::Migration
  def up
    Workon.where(coordenador: true).each do |w|
        coord_id = w.usuario.id
        Workon.where("projeto_id = ? and usuario_id != ?", w.projeto.id, coord_id).each do |z| 
          Coordenacao.new(usuario_id: coord_id, workon_id: z.id).save
        end
    end
  end

  def down
    Coordenacao.destroy_all
  end
end
