class CreateAtividadeTag < ActiveRecord::Migration
  def change
    create_table :atividades_tags do |t|
      t.belongs_to :atividade
      t.belongs_to :tag
    end
  end
end
