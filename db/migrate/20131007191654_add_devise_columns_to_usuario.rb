class AddDeviseColumnsToUsuario < ActiveRecord::Migration
  def self.up
    change_table :usuarios do |u|
      u.string :authentication_token
    end
  end
  def self.down
    u.remove :authentication_token
  end
end
