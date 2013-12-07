class RemoveMensagemFromAtividades < ActiveRecord::Migration
  def up
    remove_column :atividades, :mensagem
  end

  def down
    add_column :atividades, :mensagem, :text
  end
end
