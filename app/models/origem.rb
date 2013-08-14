class Origem < ActiveRecord::Base
  attr_accessible :nome

 has_one :recursos
end
