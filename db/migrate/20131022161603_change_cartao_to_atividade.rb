class ChangeCartaoToAtividade < ActiveRecord::Migration
  def up
    Atividade.all.each do |a|
      a.cartoes.each do |c|
        nova_atividade = Atividade.new(
          :projeto_id => a.projeto_id,
          :duracao => c.duracao.to_f * 60,
          :cartao_id => c.cartao_id,
          :usuario_id => a.usuario_id,
          :dia_id => a.dia_id,
          :aprovacao => a.aprovacao,
          :avaliador_id => a.avaliador_id,
          :observacao => a.observacao,
          :mensagem => a.mensagem,
          :data => a.data
        )
        nova_atividade.save
        a.duracao -= nova_atividade.duracao
        c.destroy
      end
      if (a.duracao == 0)
        a.destroy
      else
        a.save
      end
    end
  end

  def down
    Atividade.where("cartao_id is not null").each do |a|
      Cartao.new(
        :cartao_id => a.cartao_id,
        :duracao => a.duracao / 60,
        :atividade_id => a.id
      ).save
    end
  end
end
