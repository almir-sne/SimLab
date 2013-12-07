class ChangeMensagemInAtividadeToMensagemId < ActiveRecord::Migration
  def up
    Atividade.where{mensagem != ""}.all.each do |atividade|
      Mensagem.create(
        :atividade_id => atividade.id,
        :autor_id => atividade.avaliador_id,
        :conteudo => atividade.read_attribute(:mensagem)
      )
    end
  end

  def down
    Mensagem.all.each{ |msg| msg.atividade.update_attribute(:mensagem, msg.conteudo)}
    Mensagem.destroy_all
  end
end
