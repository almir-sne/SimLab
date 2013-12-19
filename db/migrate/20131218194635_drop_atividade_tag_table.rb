class DropAtividadeTagTable < ActiveRecord::Migration
  def change
    drop_table :atividades_tags
  end
end
