class AddMensagemToAtividades < ActiveRecord::Migration
  def change
    add_column :atividades, :mensagem, :text
  end
end
