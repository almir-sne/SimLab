class AddDeviseColumnsToUsuario < ActiveRecord::Migration
  def self.up
    change_table :usuarios do |u|
      u.string :authentication_token
    end
  end

  def down
    remove_column :usuarios, :authentication_token
  end
end
