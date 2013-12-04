class UpdateAusenciasWithProjetos < ActiveRecord::Migration
  def up
    usuarios = Usuario.all
    usuarios.each do |user|
      projetos = user.projetos
      user.ausencias.each do |falta|
        for proj in projetos
          au = Ausencia.create(
            :abonada => falta.abonada,
            :avaliador_id => falta.avaliador_id,
            :horas => falta.horas,
            :justificativa => falta.justificativa,
            :mensagem => falta.mensagem,
            :dia_id => falta.dia_id,
            :projeto_id => proj.id
          )
        end
        falta.destroy
      end
    end
  end

  def down
    falta = Ausencia.order(:dia_id).first
    Ausencia.order(:dia_id).all.each do |au|
      if au.dia_id == falta.dia_id
        au.destroy
      else
        falta = au
      end
    end
  end

end



Tentei recriar erro e estou fazendo testes



demorei fazendo a migração de volta (difícil)
