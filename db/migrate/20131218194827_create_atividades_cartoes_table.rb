class CreateAtividadesCartoesTable < ActiveRecord::Migration
  def change
    create_table :cartoes_tags do |t|
      t.belongs_to :cartao
      t.belongs_to :tag
    end
  end
end
