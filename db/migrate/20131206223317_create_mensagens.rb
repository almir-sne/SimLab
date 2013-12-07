class CreateMensagens < ActiveRecord::Migration
  def change
    create_table :mensagens do |t|
      t.text :conteudo
      t.integer :atividade_id
      t.integer :autor_id
      t.boolean :visto, :default => false

      t.timestamps
    end
  end
end
