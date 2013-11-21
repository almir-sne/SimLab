class CreateAnexos < ActiveRecord::Migration
  def change
    create_table :anexos do |t|
      t.string  :nome
      t.string  :tipo
      t.string  :arquivo
      t.integer :usuario_id
      t.date    :data
=begin
      t.binary  :arquivo_blob, :limit => 20.megabyte
      t.string  :filename
      t.string  :content_type
      t.integer :size
      t.boolean :blob
=end
      t.timestamps
    end
  end
end
