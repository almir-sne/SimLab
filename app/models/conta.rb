class Conta < ActiveRecord::Base
  attr_accessible :agencia, :banco, :numero, :usuario_id
end
