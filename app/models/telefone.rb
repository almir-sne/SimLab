class Telefone < ActiveRecord::Base
  attr_accessible :ddd, :numero, :usuario_id
end
