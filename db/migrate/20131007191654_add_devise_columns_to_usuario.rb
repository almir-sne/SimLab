class AddDeviseColumnsToUser < ActiveRecord::Migration
  def self.up
    change_table :usuarios do |u|
      u.token_authenticatable
    end
  end
  def self.down
    u.remove :authentication_token
  end
end
